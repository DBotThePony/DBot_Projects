
--
-- Copyright (C) 2017 DBot
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 

import CAMI, table from _G
import insert from table

accessToRegister = {
    {'teleport', 'Can teleport to any location by XYZ', 'admin'}
    {'logs', 'Can see DMaps logs', 'admin'}
}

for access in *{'basic', 'cami', 'team', 'ugroup'}
    insert(accessToRegister, {"view_#{access}_waypoints", "Whatever user can view '#{access}' waypoints", 'superadmin'})
	insert(accessToRegister, {"edit_#{access}_waypoints", "Whatever user can edit/create '#{access}' waypoints", 'superadmin'})
	insert(accessToRegister, {"delete_#{access}_waypoints", "Whatever user can delete '#{access}' waypoints", 'superadmin'})

CAMI.RegisterPrivilege({Name: "dmaps_#{Name}", :Description, :MinAccess}) for {Name, Description, MinAccess} in *accessToRegister