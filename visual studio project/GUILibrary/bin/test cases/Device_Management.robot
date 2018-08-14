*** Settings ***
Documentation  Contains the UI tests under qtest > TAP project > Device Management
Resource  keywords.robot
Suite Setup  Setup IntelliLink
Suite Teardown  Close IntelliLink

***Variables***
${APP_DIR}=  C:${/}Program Files (x86)${/}S&C Electric${/}IntelliLink6${/}
${APP}=  IntelliShell.exe
${IP_ADDRESS}=  169.254.235.1
${USERNAME}=  admin
${PASSWORD}=  1135Atlantic

*** Test Cases ***
UDP login
    Launch IntelliLink
    Click the "Remote Connection (Serial or IP)" button
    Select UDP/IP for Connection Type
    Enter the correct IP address of your device to the "Peer IP or DNS Name:" field
    Click the IntelliLink button
    Enter a correct Username and password
    Click the "Login" button

Phase Fault Detection Current Level Boundary Test 
    [Setup]  Navigate to Setup>General>Fault Detection
    [Teardown]  On the "Phase Fault Detection Current Level (RMS Amps)" field, enter 800 and click the enter key
    [Template]  On the "Phase Fault Detection Current Level (RMS Amps)" field, enter ${amps} and click the enter key
    -1
    8401
    -1
    10
    4200
    8400

#Firmware Update from ILink6
#    Click Tools>Firmware Update
#    Click yes to MCU OS Update
#    Click yes to MCU Application Update
#    Wait for update script to finish
#    Navigate to Setup>General>Revisions Page
#    Verify that All Installed Versions match their expected Versions
#    Verify that the settings from before the update are the same after the the update generally, but there are some exceptions, e.g. new settings.##