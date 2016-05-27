package red5
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	[RemoteClass(alias="org.red5.core.Client")]
	public class Client implements IExternalizable
	{
		
		public var name:String;
		public var address:String;
		public var vote_status:int;
		public var client_id:int;
		public var client_cer;
		public var client_type:String;
		
		public function setclient_type(type:String)
		{
			this.client_type=type;
		}
		public function getclient_type():String
		{
			return this.client_type;
		}
		public function getclient_id():int
		{
			return client_id;
		}
		
		public function setclient_id(value:int):void
		{
			client_id = value;
		}
		
		public function getclient_cer():int
		{
			return client_cer;
		}
		
		public function setclient_cer(value:int):void
		{
			client_cer = value;
		}
		
		
		public function setname(name:String)
		{
			this.name=name;
		}
		public function getname():String
		{
			return this.name;
		}
		public function getVote_status():int {
			return vote_status;
		}
		
		public function setVote_status(vote_status:int) {
			this.vote_status = vote_status;
		}
		
		public function setaddress(address:String)
		{
			this.address=address;
		}
		public function getaddress():String
		{
			return this.address;
		}
		
		
		public function readExternal(input:IDataInput):void
		{
			
			this.name= input.readObject() as String;
			this.address = input.readObject() as String;
			this.vote_status = input.readObject() as int;
			this.client_id = input.readObject() as int;
			this.client_cer = input.readObject() as int;
			this.client_type = input.readObject() as String;
			
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(this.name);
			output.writeObject(this.address);
			output.writeObject(this.vote_status);
			output.writeObject(this.client_id);
			output.writeObject(this.client_cer);
			output.writeObject(this.client_type);
		}
	}
}