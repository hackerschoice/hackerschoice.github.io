

<div style="text-align:center"><h1>WinSCP Guide For File Sharing</h1></div>

<div style="width:80%; margin:auto">
</div>

You can type here.

Check the main page how to import iamges and how to centre them and size them.

To configure winSCP to connect to segfault, press control+N to get to the window in screenshot.

![image](https://user-images.githubusercontent.com/84176052/196766269-3a872dc3-040c-4090-9259-539be97d0700.png)

Run the below code in the server instance:
```
echo $SF_FQDN
```
Change tabs to the winSCP screen, and enter the result of the code above as hostname. For me it came out to sg.segfault.net, and that is what I have entered in the hostname tab.

Username is `root` and password is `segfault`. Save this for now, we’ll come back to this later.

When you ssh in for the first time, you will see some code like instructions at the top.

![image](https://user-images.githubusercontent.com/84176052/196767165-98b738d1-0d7e-4ca4-b186-a36076473d66.png)



## No part of this or this guide is optional, skipping/modifying carelessly causes problems.


###### Make these files anywhere, we will be copying both of them to C:\Users\(yourusername)\.ssh


Part 1. For the first file, make a new file, called id_sf-de-segfault-net(name is important).
The contents should look similar to this(**do not copy/paste, it will not work!**):
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACB3jmp/3JyvY9ABgjrx4+sBnQ0T+yHsB4HTBMcJqC2OtgAAAIiJ9mzOifZs
zgAAAAtzc2gtZWQyNTUxOQAAACB3jmp/3JyvY9ABgjrx4+sBnQ0T+yHsB4HTBMcJqC2Otg
AAAEAs6YNqZSzAfZDl5/vDOB0vv7EZMxMUc/fEipuZ9A3eCHeOan/cnK9j0AGCOvHj6wGd
DRP7IewHgdMExwmoLY62AAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
```
###### Make these files anywhere, we will be copying both of them to C:\Users\(yourusername)\.ssh


For the second file, it’s largely the same.

Part 2. Create a file called config, and inside that, put the code from your server’s login screen, shown in (of the picture above)
The contents should look similar to this(do not copy/paste, it will not work!):
```
host conductmesh
    User root
    HostName sg.segfault.net
    IdentityFile ~/.ssh/id_sf-sg-segfault-net
    SetEnv SECRET=xxyyzz
```
###### The .ssh folder below might not appear if you do not have hidden files checked. Do that, or alternatively, swap out (yourusername) with, you guessed it, your username, and put that in the file explorer’s address bar.

>The keen eyed among you will have noticed the file created in Part 1(aka the private key) is being called by the file we are naming config as IdentityFile
 

Finally, put the above made files(_id_sf-de-segfault-net_ and _config_) in C:\Users\(yourusername)\.ssh folder.

For the time being, we will go back to the *config* file we created, and there, we will copy a line of code going `SetEnv SECRET=xxyyzz`. If you do not have a clipboard manager, save this, we will need this line a while later(very important. Do not modify the line either.)

On opening winSCP, you will notice a login screen(if you do not, or you accidentally closed it, press control+N). Go back to the old site you saved, click on edit:

![image](https://user-images.githubusercontent.com/84176052/196768390-7b1a9a79-3b51-42da-9aab-be28f1aca145.png)

And then go to advanced.

![image](https://user-images.githubusercontent.com/84176052/196768426-b8358a80-1fba-4027-a79a-83aa33dff609.png)

At the bottom, you will see putty terminal settings.

![image](https://user-images.githubusercontent.com/84176052/196768457-10b6ea51-7203-4149-90b5-04215e532883.png)

You will have to type in the `SetEnv SECRET=xxyyzz` you copied earlier into this field.
Now, after this is done, go to Tunnel(under Connection), you will see the following:

![image](https://user-images.githubusercontent.com/84176052/196768594-304f8ce4-74f1-4c9e-874f-df8b6dd59056.png)

Put the hostname in from earlier in the guide, username is `root` and password is `segfault`

Press on the button that the helpful red arrow is pointing to, and you will see an explorer pop up.
You have to select all files(filetype) according to the pictures.

![image](https://user-images.githubusercontent.com/84176052/196768759-3a8b36ff-719d-4ca0-a5dd-a28f72472bf6.png)

Now select the *id_sf-sg-segfault-net* file that we just created at the beginning.

###### It will show an error that the openSSH format is not supported, and instead helpfully converts it to PuTTY format. Click on ok, that is desired.


![image](https://user-images.githubusercontent.com/84176052/196769026-795cbf5d-3b4b-4080-bf55-279259f1b5bf.png)

It will now open explorer one last time*, and you select this file that just got created.

![image](https://user-images.githubusercontent.com/84176052/196769113-5e54041a-7094-4e22-9314-b3021fac5a96.png)

We are getting close to the end, last part, promise.

Now go to to Authentication under SSH.

![image](https://user-images.githubusercontent.com/84176052/196769166-d89f9ce3-dcd7-475e-9d16-fb9af75dfdde.png)

And then select the fun little button that opens up explorer from before again!

![image](https://user-images.githubusercontent.com/84176052/196769192-07fd3493-7bc9-4c4e-9226-d6ec00520f99.png)

Click on the open button, and everything should sort itself out. Click on Ok now.
 
![image](https://user-images.githubusercontent.com/84176052/196769247-44ae4cd3-06dd-45cb-a741-df330d25cec0.png)

Finally, click save, and then login.

![image](https://user-images.githubusercontent.com/84176052/196769577-348ef93d-f6ea-4f0c-9abc-9d702cb66120.png)

![image](https://user-images.githubusercontent.com/84176052/196769596-a480880b-bbbb-47d0-af6a-39185d30ac77.png)

You should see this if all went well.

![image](https://user-images.githubusercontent.com/84176052/196769624-ddb58880-4100-47c7-b184-2c379a9223ad.png)

![image](https://user-images.githubusercontent.com/84176052/196769642-213ccd47-5d55-4290-bdf4-d51e65e5486c.png)


### Contact

Twitter: [https://twitter.com/hackerschoice](https://twitter.com/hackerschoice)  
Telegram: [https://t.me/thcorg](https://t.me/thcorg)  
Web: [https://www.thc.org](https://www.thc.org)  
Medium: [https://medium.com/@hackerschoice](https://medium.com/@hackerschoice)  
E-Mail: members@thc.org  
