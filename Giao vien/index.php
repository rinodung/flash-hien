<!DOCTYPE HTML>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf8" />
	<meta name="author" content="rinodung" />

	<title>Live Room Demo</title>
</head>
<style>
body
{
	margin:10px 40%;
	position:relative;
}
input[type='submit']
{
padding:5px 24px;
}
</style>
<body >

<form action="room.php" method="post">
<table>
  
<tr>
    
</tr>

    
<tr>
    <td>Tên</td>
    <td>
        <input type='text' name='name' style='width:150px' />
    </td>
</tr>
    
<tr>
    <td>Chọn phòng</td>
    <td>
        <select name="room_id" style='width:150px'>
        <option value="1">Room1</option>
        <option value="2">Room2</option>    
		<option value="3">Room3</option>    
        </select>
    </td>
</tr>
<tr><td colspan="2"><input type="submit" value="GO" /></td></tr>

</table>
    
    
</form>

</body>
</html>