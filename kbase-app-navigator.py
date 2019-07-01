#!/usr/bin/env python3

# spec file for catalog: https://github.com/kbase/catalog/blob/master/catalog.spec

import requests
import json
import pandas
import sys
import re
import shutil
import urllib

module_name = sys.argv[1]

catalog_service_url = "https://ci.kbase.us/services/catalog" # can be ci/appdev/etc.
params = {
    "method": "Catalog.get_module_version",
    #"method": "Catalog.get_module_version",
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

result = json_resp['result'][0]
print(result)


#print(result['narrative_methods'][0])



for index, app_name in enumerate(result['narrative_methods']):
    print("App Name: "+app_name)
    print(index)
    print(result['git_url']+'/blob/master/ui/narrative/methods/'+str(app_name)+'/display.yaml')
    yamlfile_url = str(result['git_url']+"/blob/master/ui/narrative/methods/"+str(app_name)+"/display.yaml")
    r = requests.get(yamlfile_url)
    data = r.text
    for line in data.split("\n"):
        if re.search(">icon<", line):
            broken_html_line = re.compile(r"<|>").split(line)
            icon_file_name = str([s for s in broken_html_line if "png" in s])[2:-2]
            print("Icon File Name: "+icon_file_name)
            icon_html_path = result['git_url']+"/blob/master/ui/narrative/methods/"+app_name+"/img/"+icon_file_name
            print(icon_html_path)
            icon_html_path_mod = icon_html_path.replace("github","raw.githubusercontent")
            # print(icon_html_path_mod)
            try:
                urllib.request.urlretrieve(icon_html_path_mod, app_name+'.png')
            except urllib.error.HTTPError as err:
               if err.code == 404:
                   print("Page not found") #need to recommend something here
               else:
                   raise
            # response = requests.get(icon_html_path, stream=True)
            # with open(app_name+'.png', 'wb') as out_file:
            #     shutil.copyfileobj(response.raw, out_file)
            # del response
    #yamlfile = requests.get(yamlfile_url)
    #print(yamlfile.text)


##need to figure out png saving options
