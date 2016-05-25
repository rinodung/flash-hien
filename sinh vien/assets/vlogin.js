$(document).ready(function()
{	
	
	$("input#name").focus();
	$("#linklogin p").click(function(e)
	{
		openPopup();
	});
	
	$("#popup").click(function(e)
	{
		closePopup();
	});
    $("#formlogin img#close").click(function(e)
	{
		closePopup();
	});
	
	 $('*').keypress(function(e){

        if(e.keyCode=='27')
		{
			closePopup();
        }
		if(e.keyCode=='13')
		{
		
			$("#submit").click();
			return false;
		}

    });
	
	function openPopup()
	{
		$("#popup").show();
		$("#formlogin").show();
	}
	
	function closePopup()
	{
		$("#popup").hide();
		$("#formlogin").hide();
	}
    
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
	 $("#submit").click(function(event)
     {
        var mshv=$("#name").val();
		var pass=$("#pass").val();
		if(!$("#rb").is(':checked'))
		{
			alert("Bạn cần chấp nhận điều kiện về bản quyền.");
			return;
		}
        if(mshv=="")
        {
            alert("Vui lòng điền Mã Số Học Viên(MSHV)");
            $("input#name").focus();
        }
		else if(pass=="")
		{
			alert("Vui lòng điền mật khẩu");
            $("input#pass").focus();
		}
		else
		{
			
			$.ajax(
			{
				
				type:"POST",  
				url:"authen.php",				
				data:{mshv:mshv,pass:pass},
				timeout: 5000,//10s
				beforeSend: function()
					{
						$("#loading").show();
					},
				error: function (xhr, ajaxOptions, thrownError) {
					
					alert("error");
					$("#loading").hide();
				   
				},             
				success:function(result)
				{   
					if(result=="success")
					{
						

						var isOpera = !!window.opera || navigator.userAgent.indexOf('Opera') >= 0;
						// Opera 8.0+ (UA detection to detect Blink/v8-powered Opera)
						var isFirefox = typeof InstallTrigger !== 'undefined';   // Firefox 1.0+
						var isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0;
						// At least Safari 3+: "[object HTMLElementConstructor]"
						var isChrome = !!window.chrome;                          // Chrome 1+
						var isIE = /*@cc_on!@*/false;                            // At least IE6
						if(isChrome||isIE||isOpera||isFirefox||isSafari)
						{
							 $("#flogin").submit();	
							//ok

							//window.location="index2.php";
						}
						else
						{
							//buffin here
							window.location="index2.php";
						}
						/*
						document.write('isFirefox: ' + isFirefox + '<br>');
						document.write('isChrome: ' + isChrome + '<br>');
						document.write('isSafari: ' + isSafari + '<br>');
						document.write('isOpera: ' + isOpera + '<br>');
						document.write('isIE: ' + isIE + '<br>');
						*/
					  
					}
					else
					{
					   if(result=="online")
                       {
                            alert("Tài khoản đang được sử dụng bởi người khác!");
                       }
                       else
                       {
                        alert("Tài khoản không hợp lệ. Vui lòng kiểm tra và đăng nhập lại");
                       }
					
					   $("#loading").hide();
					}
					
					
				}
			});
			
		}//end elfe
		 
    });//end click submit
	
});