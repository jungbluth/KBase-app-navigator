#!/usr/bin/env python3

import sys
import urllib
import requests
import shutil
import os
# spec file for catalog: https://github.com/kbase/catalog/blob/master/catalog.spec


# This function is meant to retrieve a list of Apps from
# the KBase App Catalog, all from one page
def fetch_applist_from_url():
    import urllib.request
    import urllib.parse
    import re
    url = 'https://kbase.us/applist/'
    f = urllib.request.urlopen(url)
    with open("_kbase_apps_w_extended_information-part1.txt", "w") as out_file:
        for line in f.read().decode('utf-8').split('\n'):
            if ("module" in line):
                app_category = str(line.split(' module="')[1].split('" name="')[0])
                app_name = str(line.split(' module="')[1].split('" name="')[1].split('" id="')[0].split(" - v")[0].split("(v")[0].split(" v1.")[0].split(" 2.1")[0])
                app_module = str(line.split(' module="')[1].split('" name="')[1].split('" id="')[1].split('">')[0].split('/')[0])
                app_method = str(line.split(' module="')[1].split('" name="')[1].split('" id="')[1].split('">')[0].split('/')[1])
            if ('<img class="icon-img" src="' in line):
                app_icon_path = str(line.split('<img class="icon-img" src="')[1].split('" >')[0].replace("&amp;","&"))
                out_file.write(app_category + "\t" + app_name + "\t" + app_module + "\t" + app_method + "\t" + app_icon_path + "\n")
    out_file.close()




def retrieve_app_information(module_name):
    import json
    import pandas
    import re
    catalog_service_url = "https://ci.kbase.us/services/catalog" # can be ci/appdev/etc.
    params = {
        "method": "Catalog.get_module_version",
        "version": "1.1",
        "id": 'id',
        "params": [{
            "module_name": module_name
        }]
    }
    resp = requests.post(catalog_service_url, json.dumps(params))
    try:
        json_resp = resp.json()
    except Exception:
        raise resp.text
    #result = json_resp['result'][0]
    result = json_resp['result'][0]['git_url']
    return(result)



def download_icon(icon_url, app_name):
    try:
        urllib.request.urlretrieve(icon_url, app_name+'.png')
    except urllib.error.HTTPError as err:
       if err.code == 404:
           print("Page not found") #need to recommend something here
       else:
           raise
    response = requests.get(icon_url, stream=True)
    with open(app_name+'.png', 'wb') as out_file:
        shutil.copyfileobj(response.raw, out_file)
    del response


def fetch_info_from_app_catalog_html(app_url, module_name, app_name):
    from selenium import webdriver
    import time
    driver = webdriver.Firefox()
    url = "https://narrative.kbase.us/#catalog/apps/" + module_name + "/" + app_name + "/release"
    driver.get(url)
    time.sleep(5)
    htmlSource = driver.page_source
    #print(htmlSource)
    print("Slurping info from html/javascript for: " + app_name)
    global inputobjects
    global outputobjects
    global starcount
    global runcount
    global percentsuccess
    global timetorun
    inputobjects = []
    outputobjects = []
    for line in htmlSource.split('\n'):
        if ('<i class="fa fa-star"></i></span><span class="kbcb-star-count">' in line):
            starcount = str(line.split('<i class="fa fa-star"></i></span><span class="kbcb-star-count">')[1].split('</span>')[0])
        if ('<i class="fa fa-share"></i><span class="kbcb-run-count">' in line):
            runcount = str(line.split('<i class="fa fa-share"></i><span class="kbcb-run-count">')[1].split('</span>')[0])
        if ('<i class="fa fa-check"></i><span class="kbcb-run-count">' in line):
            percentsuccess = str(line.split('<i class="fa fa-check"></i><span class="kbcb-run-count">')[1].split('%</span>')[0])
        if ('<i class="fa fa-clock-o"></i><span class="kbcb-run-count">' in line):
            timetorun = str(line.split('<i class="fa fa-clock-o"></i><span class="kbcb-run-count">')[1].split('</span>')[0])
        if ("#spec/type" in line):
            if ("<b>Output" in line):
                t1 = line.split("<b>Output")[0].split('href="')
                t2 = line.split("<b>Output")[1].split('href="')
                for count1, line1 in enumerate(t1):
                    if ("#spec/type" in line1):
                        inputobjects.append(str(str(line1.split('<')[0].split('>')[1])))
                for count2, line2 in enumerate(t2):
                    if ("#spec/type" in line2):
                        outputobjects.append(str(str(line2.split('<')[0].split('>')[1])))
            else: # some apps don' produce output objects (e.g. if adding information to an existing object)
                t1 = line.split("<b>Output")[0].split('href="')
                for count1, line1 in enumerate(t1):
                    if ("#spec/type" in line1):
                        inputobjects.append(str(str(line1.split('<')[0].split('>')[1])))
    inputobjects = ",".join(inputobjects)
    outputobjects = ",".join(outputobjects)
    time.sleep(5)
    os.system("pkill firefox")
    #return starcount, runcount, percentsuccess, timetorun, inputobjects, outputobjects


if __name__ == '__main__':
    fetch_applist_from_url() # get initial information
    with open("_kbase_apps_w_extended_information-part2.txt", "w") as out_file:
        with open("_kbase_apps_w_extended_information-part1.txt", "r") as in_file:
            for line in in_file.read().split('\n'):
                if len(line.strip()) != 0: # ignore whitespace only lines
                    module_name = str(line.split('\t')[2])
                    app_name = str(line.split('\t')[3])
                    icon_url = str(line.split('\t')[4])
                    if ("metabat" not in line) and ("annotate_plant_transcripts" not in line) and ("run_gottcha2" not in line) and ("assembly_metadata_report" not in line) and ("domain_report" not in line) and ("genome_report" not in line) and ("genomeset_report" not in line):
                        git_repo_url = str(retrieve_app_information(module_name))
                        fetch_info_from_app_catalog_html(git_repo_url, module_name, app_name)
                        out_file.write(str(line) + '\t' + git_repo_url + '\t' + inputobjects + '\t' + outputobjects + '\t' + starcount + '\t' + runcount + '\t' + percentsuccess + '\t' + timetorun + '\n')
                        # download_icon(icon_url, app_name)
    out_file.close()
