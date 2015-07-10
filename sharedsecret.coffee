SharedSecret = [] #"SUPERSECRET"

if (Meteor.isServer)
	class EncryptMessage
		constructor: (message) ->
			currentUser = Meteor.user()._id;

			if(message.msg.indexOf('/setsecretkey ') is 0)
				secret = message.msg.split(" ")[1];
				if(secret == "off")
					secret = null
				SharedSecret[currentUser] = secret
				message.msg = "* Set a shared secret key"
				return message

			if(SharedSecret? && SharedSecret[currentUser]?)
				currentSecret = SharedSecret[currentUser]
				encrypted = CryptoJS.AES.encrypt(message.msg, currentSecret)
				message.msg = encrypted.toString()

				#urls
				if(message.urls)
					for urls in message.urls
						urls.url = CryptoJS.AES.encrypt(urls.url, currentSecret).toString()

				message.encrypted = true
				#console.log("encrypted message " + message.msg)

			return message

	RocketChat.callbacks.add 'beforeSaveMessage', EncryptMessage, 9999 #RocketChat.callbacks.priority.LOW

if (Meteor.isClient)
	class DecryptMessage
		constructor: (message) ->
			if(message.encrypted)
				currentSecret = localStorage.getItem("rocket.chat.sharedSecretKey")
				#console.log("currentSecret is : " + currentSecret)

				if(currentSecret?)
					#console.log("decrypting message " + message.msg)
					decrypted = CryptoJS.AES.decrypt(message.msg, currentSecret).toString(CryptoJS.enc.Utf8)
					#console.log("decrypted message " + decrypted)

					if(decrypted == "")
						message.msg = "~ encrypted message ~"
						message.html = "~ encrypted message ~"
					else
						message.msg = decrypted
						message.html = decrypted

					#urls
					if(message.urls)
						for urls in message.urls
							urls.url = CryptoJS.AES.decrypt(urls.url, currentSecret).toString(CryptoJS.enc.Utf8)
				else
					message.msg = "~ encrypted message ~"
					message.html = "~ encrypted message ~"

			return message

	class EncryptMessage
		constructor: (message) ->
			if(message.msg.indexOf('/setsecretkey ') is 0)
				secret = message.msg.split(" ")[1];

				if(secret == "off")
					secret = null

				localStorage.setItem("rocket.chat.sharedSecretKey", secret)
				#console.log("sharedSecretKey is: " + localStorage.getItem("rocket.chat.sharedSecretKey"))
				message.msg = "* Set a shared secret key"
				message.html = "* Set a shared secret key"
				
			return message

	RocketChat.callbacks.add 'renderMessage', DecryptMessage, -9999 #RocketChat.callbacks.priority.HIGH
	RocketChat.callbacks.add 'beforeSaveMessage', EncryptMessage, RocketChat.callbacks.priority.LOW
