# =========================================================
# Tool for rerunning previous assessments through CFE-Civil
# =========================================================
#
# Previous assessments are retrieved from a CFE-Civil database
# e.g. the production environment's RDS
#
# Assessments are submitted to CFE-Civil running on the API_BASE_URL, as defined in the code
# e.g. a locally run instance of CFE-Civil
#
# One-time setup:
# pip3 install requests psycopg2 jsondiff
#
# Environment variables to setup:
# Set POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DATABASE / POSTGRES_PORT by following:
# https://dsdmoj.atlassian.net/wiki/spaces/EPT/pages/4415946946/Database+access#Accessing-from-local-machine.1
#
# Run it:
# python3 bin/rerun_previous_assessments.py
import argparse
import json
import os
from pprint import pprint
import subprocess

import requests
import psycopg2
from jsondiff import diff as differ

API_BASE_URL = 'http://localhost:3000'
POSTGRES_PORT = os.environ["POSTGRES_PORT"]
POSTGRES_USER = os.environ["POSTGRES_USER"]
POSTGRES_PASSWORD = os.environ["POSTGRES_PASSWORD"]
POSTGRES_DATABASE = os.environ["POSTGRES_DATABASE"]

cfe_url = API_BASE_URL + '/v7/assessments'


def database_connection():
    return psycopg2.connect(database=POSTGRES_DATABASE,
                            host="localhost",
                            user=POSTGRES_USER,
                            password=POSTGRES_PASSWORD,
                            port=POSTGRES_PORT)

def get_assessment_from_database():
    with database_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SELECT request, response FROM request_logs LIMIT 1;")
            return cursor.fetchone()

def get_assessments_from_database(rows, offset=0, limit=0):
    with database_connection() as conn:
        with conn.cursor() as cursor:
            query = f"SELECT request, response FROM request_logs OFFSET {offset};"
            if limit > 0:
                query = query.replace(';', f' LIMIT {limit};')
            cursor.execute(query)
            while True:
                assessments = cursor.fetchmany(rows)
                if not assessments:
                    break
                for assessment in assessments:
                    yield assessment

def get_assessment_from_file(filepath):
    input = json.load(open(filepath, 'r'))
    return input

def json_diff(old_output_dict, output_dict):
    diff = differ(old_output_dict, output_dict, syntax='symmetric')
    diff.pop('timestamp')  # ignore
    diff['assessment'].pop('id')  # ignore
    pprint(diff)

def write_json(filepath, dict_):
        json_ = json.dumps(dict_, indent=4, sort_keys=True)
        open(filepath, 'wb').write(json_.encode('utf8'),)

def kdiff(old_output_dict, output_dict):
    write_json('/tmp/old_output.json', old_output_dict)
    write_json('/tmp/output.json', output_dict)
    subprocess.run("kdiff3 /tmp/old_output.json /tmp/output.json", shell=True)

#input = get_assessment_from_file('assessment-minimal.json')
#input_dict, old_output_dict = get_assessment_from_database()
offset = 0
limit = 0
chunk_size = 50
assessments_generator = get_assessments_from_database(chunk_size, offset, limit=limit)
for input_dict, old_output_dict in assessments_generator:
    print(offset, str(input_dict)[:100])
    if str(input_dict)[1:3] == "'{":
        print('SKIP - WEIRD FORMAT')
    else:
        input = json.dumps(input_dict)
        response = requests.post(cfe_url, data=input, headers={'Content-Type': 'application/json'})
        output_dict = response.json()
        if output_dict['success'] != old_output_dict['success']:
            print('ERROR', output_dict)
            write_json(f'/tmp/v7_validation_error_{POSTGRES_PORT}_{offset}.json', input_dict)
            # kdiff(old_output_dict=old_output_dict, output_dict=output_dict)
    offset += 1


#print(input)
# response = requests.post(cfe_url, data=input, headers={'Content-Type': 'application/json'})
# output_dict = response.json()
# assert output_dict['success'], output_dict

# kdiff(old_output_dict=old_output_dict, output_dict=output_dict)
#print(json.dumps(output_dict, indent=4))

# if __name__ == '__main__':
#     parser = argparse.ArgumentParser()
#     parser.add_argument("echo")
#     args = parser.parse_args()
#     print(args.echo)