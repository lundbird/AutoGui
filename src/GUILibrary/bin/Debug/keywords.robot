***Settings***
Resource  Keywords.robot  #as this test suite expands put the keywords in a resource file
Library  OperatingSystem
Library  Process
Library  GUILibraryPy

***Variables***
${LastAmps}=  800

***Keywords***
Setup IntelliLink
    Directory Should Exist  ${APP_DIR}
    File Should Exist  ${APP_DIR}${APP}
Close IntelliLink
    Terminate All Processes
Launch IntelliLink
    Start Process  ${APP_DIR}${APP}
Click the "Remote Connection (Serial or IP)" button
    setWindow  SC IntelliShell - Select Connection Mode
	click  Id:RemoteConnectionButton  
Select UDP/IP for Connection Type
    setWindow  SC IntelliShell Remote
	click  Id:radioButton2UDP  
Enter the correct IP address of your device to the "Peer IP or DNS Name:" field
	write  ${IP_ADDRESS}  Id:textBox2PeerIPorDNS  
Click the IntelliLink button
	click  Id:buttonStartIL  
    sleep  4 
Enter a correct Username and password
    setWindow  S&C IntelliLink Setup Software [611.23]
	write  admin  Id:LoginWindowTextBoxLoginId 
	write  1135Atlantic  Id:LoginWindowPasswordBoxId  
Click the "Login" button
	click  Id:LoginWindowButtonLoginId  


#Phase Fault Detection Current Level Boundary Test
Navigate to Setup>General>Fault Detection
    setWindow  SG6801(#1) - S&C IntelliLink Setup Software [611.23]
    click  title:Setup,class:TextBlock
    click  title:General,class:TextBlock 
    click  Fault Detection 
On the "Phase Fault Detection Current Level (RMS Amps)" field, enter ${amps} and click the enter key
    write  ${amps}  value:${LastAmps}
    press  enter
    Run Keyword If  ${amps}>0 and ${amps}<8400  Valid Input
    Run Keyword If  ${amps}<0 or ${amps}>8400  Invalid Input
    ${LastAmps}=  Set Variable  ${amps}
    Set Global Variable  ${LastAmps}
Invalid Input
    click  OK
Valid Input
    click  Validate
    read  iaccessiblevalue:=Settings Validation Successful
    click  Apply
    read  iaccessiblevalue:=Settings Applied Successfully

#Firmware Update from ILink6
Click Tools>Firmware Update
Click yes to MCU OS Update
Click yes to MCU Application Update
Wait for update script to finish
Navigate to Setup>General>Revisions Page
Verify that All Installed Versions match their expected Versions
Verify that the settings from before the update are the same after the the update generally, but there are some exceptions, e.g. new settings.