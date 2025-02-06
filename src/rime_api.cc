//
// Copyright RIME Developers
// Distributed under the BSD License
//
// 2011-08-09 GONG Chen <chen.sst@gmail.com>
//

#include "rime_api_impl.h"

#include <cstring>
#include <sstream>
#include <rime/common.h>
#include <rime/module.h>
#include <rime/setup.h>
#include <rime/dict/user_dictionary.h>
#include <vector>

using namespace rime;

RIME_DEPRECATED void RimeSetupLogging(const char* app_name) {
  SetupLogging(app_name);
}

#if RIME_BUILD_SHARED_LIBS
void rime_declare_module_dependencies() {}
#else
extern void rime_require_module_core();
extern void rime_require_module_dict();
extern void rime_require_module_gears();
extern void rime_require_module_levers();
// link to default modules explicitly when building static library.
void rime_declare_module_dependencies() {
  rime_require_module_core();
  rime_require_module_dict();
  rime_require_module_gears();
  rime_require_module_levers();
}
#endif

RIME_API Bool RimeRegisterModule(RimeModule* module) {
  if (!module || !module->module_name)
    return False;
  ModuleManager::instance().Register(module->module_name, module);
  return True;
}

RIME_API RimeModule* RimeFindModule(const char* module_name) {
  return ModuleManager::instance().Find(module_name);
}

void RimeGetSharedDataDirSecure(char* dir, size_t buffer_size) {
  string string_path = Service::instance().deployer().shared_data_dir.string();
  strncpy(dir, string_path.c_str(), buffer_size);
}

void RimeGetUserDataDirSecure(char* dir, size_t buffer_size) {
  string string_path = Service::instance().deployer().user_data_dir.string();
  strncpy(dir, string_path.c_str(), buffer_size);
}

void RimeGetUserDictEntries(const char* dict_name,UserDictData* data){
  auto component = UserDictionary::Require("user_dictionary");
  string dict_type = "userdb";
  auto dict = ((UserDictionaryComponent*)component)->Create(dict_name,dict_type);
  if(!dict->loaded())
      dict->Load();
  auto db = dict->db();
  auto acc = db->QueryAll();
  string key,value;
  auto entry_list=vector<UserDictEntry>();
  while (!acc->exhausted())
  {
    if(acc->GetNextRecord(&key,&value))
    {
      auto entry=UserDictEntry();
      entry.key=new char[key.length()+1];
      strcpy(entry.key,key.c_str());
      entry.value = new char[value.length()+1];
      strcpy(entry.value,value.c_str());
      entry_list.push_back(entry);
    }
  }
  data->count = entry_list.size();
  data->entries = new UserDictEntry[entry_list.size()];
  memcpy(data->entries,entry_list.data(),sizeof(UserDictEntry)*entry_list.size());
}


void RimeReleaseUserDictEntries(UserDictData* data){
  for(int i=0,count= data->count;i<count;i++)
  {
    auto entry=data->entries[i];
    delete[] entry.key;
    delete[] entry.value;
  }
  delete[] data->entries;
}

Bool RimeDeleteUsrDictEntry(const char* dict_name,const char* key){
  auto component = UserDictionary::Require("user_dictionary");
  string dict_type = "userdb";
  auto dict = ((UserDictionaryComponent*)component)->Create(dict_name,dict_type);
  if(!dict->loaded())
      dict->Load();
  auto db = dict->db();
  return db->Erase(key);
}

void RimeGetPrebuiltDataDirSecure(char* dir, size_t buffer_size) {
  string string_path =
      Service::instance().deployer().prebuilt_data_dir.string();
  strncpy(dir, string_path.c_str(), buffer_size);
}

void RimeGetStagingDirSecure(char* dir, size_t buffer_size) {
  string string_path = Service::instance().deployer().staging_dir.string();
  strncpy(dir, string_path.c_str(), buffer_size);
}

void RimeGetSyncDirSecure(char* dir, size_t buffer_size) {
  string string_path = Service::instance().deployer().sync_dir.string();
  strncpy(dir, string_path.c_str(), buffer_size);
}

const char* RimeGetVersion() {
  return RIME_VERSION;
}
