from flask import Flask, render_template, request
import requests
from dataclasses import dataclass
import json


app =  Flask(__name__)


#hitting the ipinfo API to fetch dtaa in case the checkbox is checked
@app.route('/geolocationCoordinate')
def fetch_geolocation_coordinate():
    response = requests.get(f"https://ipinfo.io/?token=ef2cd709c85551").json()
    return response

#hitting the weather API to fetch the various weather fields required in the elements
#for this we make use of tomorrow.io API by providing it the oordinates 
#for getting the coordinates we make use of ipinfo API when street and other details are not mentioned
#google geocoding API when these details are mentioned
@app.route('/weather')
def fetch_weather_details():
    coordinates = request.args.get("coordinates")
    timesteps = request.args.get("timesteps")
    weatherDataFields = json.loads(request.args.get("weatherDataFields"))
    startTime = request.args.get("startTime")
    endTime= request.args.get("endTime")
    
    payload = {
        "location": coordinates,
        "fields": weatherDataFields,
        "units": "imperial",
        "timesteps": [timesteps],
        "timezone": "America/Los_Angeles"
    }

    if(startTime):
        payload['startTime']=startTime

    if(endTime):
        payload['endTime']=endTime

    headers = {
        "accept": "application/json",
        "Accept-Encoding": "gzip",
        "content-type": "application/json"
    }

    response = requests.post(f"https://api.tomorrow.io/v4/timelines?apikey=hKYen1VV41mZiz2XIQJPjGhm8PACE1M1",json=payload,headers=headers).json()
    return response

#fetching the coordiates when the strrt, city, and state are entered 
#if some bogus street and city are given just use the state to get the coordinates
@app.route('/coordinates')
def fetch_coordinates(): 
    address = request.args.get('address')
    state = request.args.get('state')
    full_address = address + " " + state
    response = requests.get(f"https://maps.googleapis.com/maps/api/geocode/json?address={full_address}&extra_computations=ADDRESS_DESCRIPTORS&key=AIzaSyAig7i8JmSejtz8_rdpaDOdcFj4JOxU130").json()
    if response["results"]:
        return response
    else: 
        state = state + " , USA"
        return requests.get(f"https://maps.googleapis.com/maps/api/geocode/json?address={state}&extra_computations=ADDRESS_DESCRIPTORS&key=AIzaSyAig7i8JmSejtz8_rdpaDOdcFj4JOxU130").json()
    


@app.route('/')
def index():
    # street_name = request.form.get("street")
    # city_name = request.form.get("city")
    # state_name = request.form.get("state")

    # print(state_name)

    return render_template('weather.html')
    # return "hello_world"

if __name__ == '__main__':  
    app.run(port=8080,debug=True)