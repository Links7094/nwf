--
-- init script for helloworld module
-- Author: elvin
-- Date: 17-3-24
-- Time: 10:46
-- desc: this script will be load at mvc framework loaded..
--

print("helloworld module init...");

NPL.load("(gl)www/modules/helloworld/HelloModController.lua");
NPL.load("(gl)www/modules/helloworld/HelloModValidator.lua");