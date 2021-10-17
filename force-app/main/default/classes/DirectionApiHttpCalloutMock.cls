/**
 * @description       : 
 * @author            : Andreea Ionescu BearingPoint GmbH
 * @group             : 
 * @last modified on  : 10-18-2021
 * @last modified by  : Andreea Ionescu, BearingPoint GmbH
**/
public class DirectionApiHttpCalloutMock implements HttpCalloutMock{
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"geocoded_waypoints" : [], "routes" : [{"bounds" : { "northeast" : { "lat" : 44.4551773,"lng" : 26.0518107},"southwest" : {"lat" : 44.433912,"lng" : 26.0158557}},"copyrights" : "Map data ©2021","legs" : [{"distance" : {"text" : "4.8 km", "value" : 4845}, "steps" : []},{"distance" : {"text" : "4.4 km","value" : 4371},"steps" : []}]}],"status" : "OK"}');

        response.setStatusCode(200);
        return response;
    
    }
}   
