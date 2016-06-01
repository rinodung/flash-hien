package red5
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	[RemoteClass(alias="org.red5.core.User")]
	public class User implements IExternalizable
	{
		public var id:String;
		public var name:String;
		public function User()
		{
			this.id="09520044";
			this.name="Dung";
		}
		public function setId(id:String)
		{
		this.id=id;
		}
		public function getId():String
		{
			return this.id;
		}
		
		public function setName(name:String)
		{
			this.name=name;
		}
		public function getName():String
		{
			return this.name;
		}
		public function readExternal(input:IDataInput):void
		{
			
			this.id = input.readObject() as String;
			this.name = input.readObject() as String;
			
		}
		
		public function writeExternal(output:IDataOutput):void
		{
			output.writeObject(id);
			output.writeObject(name);
			      
		}
	}
}