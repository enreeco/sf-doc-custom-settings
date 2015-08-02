# Custom Settings: How and Why

## Intro

One of the greatest pros of the Force.com platform is the extraordinary quick development phase: even when you are under continous software development, you can change your processes implementation within minutes.

With great features come great responsibilities, that’s why you should give administrators, who may not be developers, the same power to configure the code flow.

Before the introduction of custom settings, the only options were:

- Hard coding constants on your classes
    
    Pros:

        - Simple to handle for developers
    
    Cons:

        - You need a deploy every time you need to change a value

- Creating custom objects where storing your configuration (even if only 1 set of data)
    
    Pros:

        - High flessibility
    
    Cons:

        - You need to do a query every time you need a configuration value (this could be painfull in large and complex implementations)

The introduction of Custom settings made our days!

## Let's do it

Let's start with a simple Visual Force page that shows, calling a public API, a random quote, *QuoteOfTheDay.page*:

```html
<apex:page controller="QuoteOfTheDayController" action="{!onLoad}" tabStyle="Idea">
    
    <b><apex:outputText value="{!qod}" escape="false" /></b>
     
    <i>{!author}</i>
    
    <hr />
    
    <i>Quote of the day - <b>{!dt}</b></i>
    
    <br/> 
    
    <apex:pageBlock rendered="{!DEBUG_MODE}">
        <apex:pageBlockSection  title="Callout details" columns="1">
        
            <apex:pageBlockSectionItem>
                <apex:outputLabel value="Endpoint" />
                <apex:outputPanel>{!CALLOUT_ENDPOINT}</apex:outputPanel>
            </apex:pageBlockSectionItem>
            
            <apex:pageBlockSectionItem>
                <apex:outputLabel value="Timeout" />
                <apex:outputPanel>{!CALLOUT_TIMEOUT}</apex:outputPanel>
            </apex:pageBlockSectionItem>
            
            <apex:pageBlockSectionItem>
                <apex:outputLabel value="Error Message" />
                <apex:outputPanel>{!errorMessage}</apex:outputPanel>
            </apex:pageBlockSectionItem>
            
        </apex:pageBlockSection>
        
    </apex:pageBlock>
    
</apex:page>
```

```java
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
            this.qod = 'Something bad happened. Please reload';
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

```

The controller, on page load:

* Stores date/time of request
* Creates an HttpRequest setting its endpoint, timeout, method (GET)
* Sends the request and parses the response (getting the quote and the author)
* Formats the date of call execution depending of current User's locale

The DEBUG_MODE allow to see some info about the current callout (for debug porpouses).

On the page controller we have no configuration, because they are written on the following utility class:

```java
public class ConfigurationManager{
    
    //global endpoint
    public static String CALLOUT_ENDPOINT{
        get{
            return 'http://quotesondesign.com/wp-json/posts?filter[orderby]=rand';
        }
    }

    //global timeout in ms
    public static Integer CALLOUT_TIMEOUT{
        get{
            return 60000;
        }
    }

    //user/profile centric debug mode
    public static Boolean DEBUG_MODE{
        get{
            return false;
        }
    }

    //returns a specific date format given the locale code
    public static String getDateFormat(String localeCode){
        if(localeCode == 'it_IT'){
            return 'dd/MM/yyyy';
        }
        return 'MM/dd/yyyy';
    }

}
```

Before running the page remember to add the *http://quotesondesign.com* endpoint among the trusted endpoints for the ORG, by selecting *Setup* > *Security Controls* > *Remote Siste Settings*.

![](/images/img1.png?raw=true)

Now let's open the page:

![](/images/img2.png?raw=true)

You can change the hardcoded configurations on the *ConfigurationManager* class: let's set the DEBUG_MODE variable to true:

![](/images/img3.png?raw=true)

This example clearly shows that it is hard, for non developers, to alter the configurations.

Here come the *Custom Settings*: they are Custom Objects that can be used without making any DML and are fitted to current User's context.

Let's create a new Custom Setting with *Setup* > *Custom Settings* > *New*:

![](/images/img4.png?raw=true)

The Hierarchic custom setting is a setting that has a global value for its fields which can be overridden on a per User / User's Profile basis.

This will be more clear after the custom setting configuration.

A Custom Setting is just like a Custom SObject, so you can add all fields you want (with some exceptions on the types):

![](/images/img5.png?raw=true)

To set a value for the fields, click on the *Manage* button and then on the *Edit* button:

![](/images/img6.png?raw=true)

These are global values for the fields and they will be the only values we will be needing for this custom setting.

Set the same values we have on the *ConfigurationManager* class.

Let's create another Custom Setting for the DEBUG_MODE flag:

![](/images/img7.png?raw=true)

Let's set a global value with *Manage* > *Edit*:

![](/images/img8.png?raw=true)

Then click the *New* button on the lower section of the "Manage" page and add new values for the "System Administrator" profile:

![](/images/img9.png?raw=true)

This means that the *Debugging* custom setting will have a global value and a value fitted for System Administrator users: every administrator that will execute the page will see the debug section.

Finally let's add the last custom setting for the date formats, by choosing a *List* type:

![](/images/img10.png?raw=true)

With the following fields:

![](/images/img11.png?raw=true)

This time, when creating a new value, we'll have a set of values (remember the *List*) type instead of global/user/profile values, each one identified by a *Name* field:

![](/images/img12.png?raw=true)

For each locale codes you can set a specific date format plus a Default value (to be handled manually).

Now that we have create all the settings, we need to link them to the code, so let's change the *ConfigurationManager* class accordingly:

```java
public class ConfigurationManager{
    
    //global endpoint
    public static String CALLOUT_ENDPOINT{
        get{
            //return 'http://quotesondesign.com/wp-json/posts?filter[orderby]=rand';
            return Endpoints__c.getOrgDefaults().Callout_Endpoint__c;
        }
    }

    //global timeout in ms
    public static Integer CALLOUT_TIMEOUT{
        get{
            //return 60000;
            return Endpoints__c.getOrgDefaults().Callout_Timeout__c.intValue();
        }
    }

    //user/profile centric debug mode
    public static Boolean DEBUG_MODE{
        get{
            //return true;
            return Debugging__c.getInstance().Callout_Debug_Mode__c;
        }
    }

    //returns a specific date format given the locale code
    public static String getDateFormat(String localeCode){
        
        //if(localeCode == 'it_IT'){
        //    return 'dd/MM/yyyy';
        //}
        //return 'MM/dd/yyyy';*/
        Date_Formats__c defaultFormat = Date_Formats__c.getInstance('Default');
        Date_Formats__c localeFormat = Date_Formats__c.getInstance(localeCode);
        if(localeFormat != null) return localeFormat.Format__c;
        return defaultFormat.Format__c;
    }

}
```