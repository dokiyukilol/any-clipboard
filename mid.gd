extends Node
var aes:AESContext
var KEY = "My secret key!!!"# 密钥必须是 16 或 32 字节。
var PREFIX = "SADWXFCZXF" # 用来确认解密后的内容正确性
var SPACE = "/" # 末尾填充用字符,不应该与消息内容重复
var ENC_MAXLEN = 16 # 最大加密长度( *16)

# 将data补全为16倍数(ASCII)
func to16mult(data:String) -> String:
	"""将字符串变成16倍
	"""
	
	var len_data = len(data) 
	var len_ans = 0
	if len_data % 16 == 0:
		return data
		 
	for i in range(ENC_MAXLEN):
		len_ans = i*16
		assert(i<ENC_MAXLEN-2,"加密内容过长")
		if len_ans >= len_data:
			break
	for i in range(len_ans - len_data):
		data += SPACE
	return data

# 将data补全为16倍数后 通过AES加密为PacketByteArray
func encode(data:String) -> PackedByteArray:
	data = to16mult(data)
	aes.start(AESContext.MODE_ECB_ENCRYPT, KEY.to_ascii_buffer())
	var encrypted = aes.update(data.to_ascii_buffer())
	aes.finish()
	return encrypted
	
# 通过AES解密为String(ASCII) 后去除空白的补全字符
func decode(data:PackedByteArray) -> String:
	aes.start(AESContext.MODE_ECB_DECRYPT, KEY.to_ascii_buffer())
	var decrypted:String = aes.update(data).get_string_from_ascii()
	aes.finish()
	decrypted = decrypted.replace(SPACE,"")
	return decrypted

# 添加前缀
func pad_prefix(data:String) -> String:
	return PREFIX + data 

# 去除前缀
func remove_prefix(data:String) -> String:
	return data.right(len(data) - len(PREFIX))

# 确认是否包含前缀 以验证解密后的消息是否合法
func check_prefix(data:String) -> bool:
	var prefix = data.left(len(PREFIX))
	return prefix == PREFIX

func _ready() -> void:
	aes = AESContext.new()
