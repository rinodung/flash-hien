$(document).ready(function()
{	
	
     $("#wrapper #top").SetScroller({	velocity: 	 30,
											direction: 	 'horizontal',
											startfrom: 	 'left',
											loop:		 'infinite',
											movetype: 	 'pingpong',
											onmouseover: 'pause',
											onmouseout:  'play',
											onstartup: 	 'play',
											cursor: 	 'pointer'
					
                    					});
                                         
     active();	
     
	 
    
    function active()
     {
        var mshv=$("span#username").html();
        	$.ajax(
			{				
				type:"POST",  
				url:"active.php",				
				data:{mshv:mshv},
				timeout: 5000,//10s				
				success:function(result)
				{   
				    tempt=$("span#info").html();
				    $("span#info").html(tempt+" "+mshv);
                   
				}
			});
        setTimeout(function(){active()},8000); //1phut
        
     }
	
});