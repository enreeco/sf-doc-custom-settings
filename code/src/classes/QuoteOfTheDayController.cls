public with sharing class QuoteOfTheDayController {
	
	public String CALLOUT_ENDPOINT{
		get{
			return ConfigurationManager.CALLOUT_ENDPOINT;
		}
	}
	
	public Integer CALLOUT_TIMEOUT{
		get{
			return ConfigurationManager.CALLOUT_TIMEOUT;
		}
	}
	
	public Boolean DEBUG_MODE{
		get{
			return ConfigurationManager.DEBUG_MODE;
		}
	}
	
	public String DATE_FORMAT{
		get{
			return ConfigurationManager.getDateFormat(UserInfo.getLocale());
		}
	}
	
	//quote of the day
	public String qod{get;Set;}
	//quote of the day author
	public String author{get;Set;}
	//date of request
	public String dt{get;set;}
	//debug message
	public String errorMessage{get;Set;}
	
	//loads the Quote of the Day on load
	public void onLoad(){
		
		//date of callout
		DateTime dateOfCall = System.now();
		
		try{
			Http h = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(CALLOUT_ENDPOINT);
			request.setTimeout(CALLOUT_TIMEOUT);
			request.setMethod('GET');
			HttpResponse response = h.send(request);
			List<String> result = getQuoteFromResponse(response);
			this.qod = result[0];
			this.author = result[1];
		}catch(Exception e){
			this.qod = ' Something bad happened. Please reload';
			this.errorMessage = e.getMessage();
		}
		this.dt = dateOfCall.format(DATE_FORMAT);
	}
	
	/*
    Parse the "Quote Of The Day" API response (details @ http://quotesondesign.com/api-v4-0/)
    @return - List<String> contains 0 => quote, 1 => author 
    */
    public static List<String> getQuoteFromResponse(HttpResponse response){
    	String resp = response.getBody();
    	List<Object> jsonResponse = (List<Object>)JSON.deserializeUntyped(resp);
    	Map<String,Object> quote = (Map<String,Object>)jsonResponse[0];
    	String quoteString = (String)quote.get('content');
    	String authorString = (String)quote.get('title');
    	return new List<String>{quoteString, authorString};
    }
	
	public class CustomException extends Exception{}
}