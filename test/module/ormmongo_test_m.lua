local skynet = require "skynet"
local ormtable = require "ormtable"
local ormadapter_mongo = require "ormadapter_mongo"
local math_util = require "math_util"
local string_util = require "string_util"
local table_util = require "table_util"
local mongof = require "mongof"
local log = require "log"

local assert = assert

local CMD = {}

local function delete_table()
    mongof.instance("admin").t_player:drop()
end

--测试创建表
local function test_create_table(is_del)
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :int16("sex2")
    :uint16("sex3")
    :int32("sex4")
    :uint32("sex5")
    :int64("sex6")
    :string128("sex7")
    :string256("sex8")
    :string512("sex9")
    :string1024("sex10")
    :string2048("sex11")
    :string4096("sex12")
    :string8192("sex13")
    :text("sex14")
    :blob("sex15")
    :set_keys("player_id","role_id","sex")
    :builder(adapter)

    return orm_obj
end

--测试修改表
local function test_alter_table()
    test_create_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :int8("nickname1")
    :set_keys("player_id","role_id","sex")
    :builder(adapter)

    delete_table()
end

--测试新增数据
local function test_create_entry()
    local orm_obj = test_create_table()

    --新建单条数据
    local new_data = {player_id = 10001,role_id = 1, sex = 1}
    local res = orm_obj:create_entry(new_data)
    local entry = assert(res[1]) 
    assert(entry:get('player_id') == 10001)
    assert(entry:get('role_id') == 1)
    assert(entry:get('sex') == 1)
    assert(entry:get('nickname') == "") --没有设置的string 会默认给个空 string
    assert(entry:get('sex1') == 0)      --没有设置的number 会默认给个 0

    --主键冲突
    local new_data = {player_id = 10001,role_id = 1, sex = 1}
    local res = orm_obj:create_entry(new_data)
    assert(res[1] == false)     

    --缺少主键数据
    local new_data = {player_id = 10001,role_id = 2}
    local isok,res = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok) --会崩溃报错

    --新建多条数据
    local new_data_list = {
        {player_id = 10002,role_id = 1, sex = 1},
        {player_id = 10002,role_id = 2, sex = 1},
        {player_id = 10002,role_id = 3, sex = 1}
    }

    local res = orm_obj:create_entry(table.unpack(new_data_list))
    assert(#res == 3)
    for i,v in pairs(res) do
        assert(v)
    end

    -- 新增数据值范围要合理

    local new_data = {player_id = 100055,role_id = 1, sex = -128}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 10005,role_id = 1, sex = -129}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 10006,role_id = 1, sex = 128}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 100066,role_id = 1, sex = 127}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)
    
    local new_data = {player_id = 10007,role_id = 1, sex = 1, sex1 = 256}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 100077,role_id = 1, sex = 1, sex1 = 255}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 10008,role_id = 1, sex = 1, sex1 = -1}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 100088,role_id = 1, sex = 1, sex1 = 0}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 11007,role_id = 1, sex = 1, sex2 = 32768}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 110077,role_id = 1, sex = 1, sex2 = 32767}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 11008,role_id = 1, sex = 1, sex2 = -32769}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 110088,role_id = 1, sex = 1, sex2 = -32768}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 12007,role_id = 1, sex = 1, sex3 = 65536}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 120077,role_id = 1, sex = 1, sex3 = 65535}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 12008,role_id = 1, sex = 1, sex3 = -1}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 120088,role_id = 1, sex = 1, sex3 = 0}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 13007,role_id = 1, sex = 1, sex4 = 2147483648}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 130077,role_id = 1, sex = 1, sex4 = 2147483647}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 13008,role_id = 1, sex = 1, sex4 = -2147483649}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 130088,role_id = 1, sex = 1, sex4 = -2147483648}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 14007,role_id = 1, sex = 1, sex5 = 4294967296}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 140077,role_id = 1, sex = 1, sex5 = 4294967295}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 14008,role_id = 1, sex = 1, sex5 = -1}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 140088,role_id = 1, sex = 1, sex5 = 0}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 15007,role_id = 1, sex = 1, sex6 = 9223372036854775808}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local new_data = {player_id = 150077,role_id = 1, sex = 1, sex6 = 9223372036854775807}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local new_data = {player_id = 15008,role_id = 1, sex = 1, sex6 = -9223372036854775809}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok and err[1] ~= false)  --插入成功 数据会被修正为-9223372036854775808  

    local new_data = {player_id = 150088,role_id = 1, sex = 1, sex6 = -9223372036854775808}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok and err[1] ~= false) --插入成功 

    local test_str = ""
    for i = 1,33 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10009,role_id = 1, sex = 1, nickname = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,32 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100099,role_id = 1, sex = 1, nickname = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,65 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10010,role_id = 1, sex = 1, email = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,64 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100100,role_id = 1, sex = 1, email = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,129 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10011,role_id = 1, sex = 1, sex7 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,128 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100111,role_id = 1, sex = 1, sex7 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,257 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10012,role_id = 1, sex = 1, sex8 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,256 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100122,role_id = 1, sex = 1, sex8 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,513 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10013,role_id = 1, sex = 1, sex9 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,512 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100133,role_id = 1, sex = 1, sex9 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,1025 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10014,role_id = 1, sex = 1, sex10 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,1024 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100144,role_id = 1, sex = 1, sex10 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,2049 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10015,role_id = 1, sex = 1, sex11 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    
    local test_str = ""
    for i = 1,2048 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100155,role_id = 1, sex = 1, sex11 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,4097 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10016,role_id = 1, sex = 1, sex12 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,4096 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100166,role_id = 1, sex = 1, sex12 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    local test_str = ""
    for i = 1,8193 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 10017,role_id = 1, sex = 1, sex13 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(not isok)

    local test_str = ""
    for i = 1,8192 do
        test_str = test_str .. 'i'
    end
    local new_data = {player_id = 100177,role_id = 1, sex = 1, sex13 = test_str}
    local isok,err = pcall(orm_obj.create_entry,orm_obj,new_data)
    assert(isok)

    delete_table()
end

--测试查询数据
local function test_select_entry()
    local orm_obj = test_create_table()
    --新建多条数据
    local new_data_list = {
        {player_id = 10002,role_id = 1, sex = 1},
        {player_id = 10002,role_id = 2, sex = 1},
        {player_id = 10002,role_id = 2, sex = 2},
        {player_id = 10002,role_id = 3, sex = 2},
        {player_id = 10003,role_id = 1, sex = 1},
        {player_id = 10003,role_id = 2, sex = 1},
        {player_id = 10003,role_id = 2, sex = 2},
        {player_id = 10003,role_id = 3, sex = 2},
    }

    local res = orm_obj:create_entry(table.unpack(new_data_list))
    assert(#res == 8)
    for i,v in pairs(res) do
        assert(v)
    end

    --通过player_id查询
    local entry_list = orm_obj:get_entry(10002)
    assert(#entry_list == 4) --有四条数据
    for i,entry in ipairs(entry_list) do
        assert(entry:get('player_id') == new_data_list[i].player_id)
        assert(entry:get('role_id') == new_data_list[i].role_id)
        assert(entry:get('sex') == new_data_list[i].sex)
    end

    --通过player_id 加 role_id 查询
    local entry_list = orm_obj:get_entry(10002,2)
    assert(#entry_list == 2) --有2条数据

    --通过player_id 加 role_id 加 sex 查询
    local entry_list = orm_obj:get_entry(10002,2,1)
    assert(#entry_list == 1) --有1条数据

    --查询不存在的数据
    local entry_list = orm_obj:get_entry(10004)
    assert(#entry_list == 0)
    local entry_list = orm_obj:get_entry(10004,1)
    assert(#entry_list == 0)
    local entry_list = orm_obj:get_entry(10004,1,1)
    assert(#entry_list == 0)

    --查询版本一用，版本二不用，版本三再用，字段取出不能为nil
    
    --版本二只有3个主键
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :set_keys("player_id","role_id","sex")
    :builder(adapter)

    local res = orm_obj:create_entry({player_id = 10004,role_id = 1, sex = 1})
    assert(#res == 1 and res[1])

    --版本三又用回来
    orm_obj = test_create_table()
    local entry_list = orm_obj:get_entry(10004)
    local entry = assert(entry_list[1])
    
    assert(entry:get('nickname') == "")
    assert(entry:get('sex4') == 0)

    delete_table()
end

--测试变更保存数据
local function test_save_entry()
    delete_table()
    local orm_obj = test_create_table()
    local res = orm_obj:create_entry({player_id = 10004,role_id = 1, sex = 1, nickname = "ddasda", sex1 = 222})
    local entry = assert(res[1])
    
    --主键值不能修改
    local isok = pcall(entry.set,entry,'player_id',1000)
    assert(not isok)
    local isok = pcall(entry.set,entry,'role_id',1000)
    assert(not isok)
    local isok = pcall(entry.set,entry,'sex',2)
    assert(not isok)

    --修改数据范围要合理
    local isok = pcall(entry.set,entry,'sex1',256)
    assert(not isok)

    local isok = pcall(entry.set,entry,'sex1',-1)
    assert(not isok)

    local isok = pcall(entry.set,entry,'nickname',"1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111")
    assert(not isok)

    --修改单条数据
    entry:set('nickname',"abcde")
    entry:set('sex1',111)

    local res = orm_obj:save_entry(entry)
    assert(res[1] == true)

    local entry_list = orm_obj:get_entry(10004)
    local entry = assert(entry_list[1])
    assert(entry:get('nickname') == "abcde")
    assert(entry:get('sex1') == 111)

    --修改多条数据
    local res = orm_obj:create_entry(
        {player_id = 11001,role_id = 1, sex = 1, nickname = "abcd", sex1 = 1},
        {player_id = 11002,role_id = 1, sex = 1, nickname = "efgh", sex1 = 2}
    )
    local entry1 = assert(res[1])
    entry1:set('nickname',"abcde")
    entry1:set('sex1',111)
    local entry2 = assert(res[2])
    entry2:set('nickname',"efghg")
    entry2:set('sex1',222)

    local res = orm_obj:save_entry(entry1, entry2)
    assert(res[1])
    assert(res[2])

    local res = orm_obj:get_entry(11001)
    entry1 = assert(res[1])

    local res = orm_obj:get_entry(11002)
    entry2 = assert(res[1])

    assert(entry1:get('nickname') == "abcde")
    assert(entry1:get('sex1') == 111)

    assert(entry2:get('nickname') == "efghg")
    assert(entry2:get('sex1') == 222)

    delete_table()
end

--测试删除数据
local function test_delete_entry()
    local orm_obj = test_create_table()
    local res = orm_obj:create_entry(
        {player_id = 10004,role_id = 1, sex = 1, nickname = "ddasda", sex1 = 222},
        {player_id = 10004,role_id = 1, sex = 2, nickname = "ddasda", sex1 = 223},
        {player_id = 10004,role_id = 1, sex = 3, nickname = "ddasda", sex1 = 224},
        {player_id = 10004,role_id = 2, sex = 1, nickname = "ddasda", sex1 = 222},
        {player_id = 10004,role_id = 2, sex = 2, nickname = "ddasda", sex1 = 223},
        {player_id = 10004,role_id = 2, sex = 3, nickname = "ddasda", sex1 = 224},
        {player_id = 10004,role_id = 3, sex = 3, nickname = "ddasda", sex1 = 224},
        {player_id = 10005,role_id = 2, sex = 1, nickname = "ddasda", sex1 = 224}
    )

    --删除一条数据 （使用三个关联唯一key）
    local res = orm_obj:delete_entry(10004, 1, 1)
    assert(res)

    local entry_list = orm_obj:get_entry(10004, 1, 1)
    assert(not next(entry_list))

    --应该还有两条数据
    local entry_list = orm_obj:get_entry(10004, 1)
    assert(#entry_list == 2)

    --删除数据 （使用 2个 关联 key）
    local res = orm_obj:delete_entry(10004, 1)
    assert(res)

    --应该还有四条数据
    local entry_list = orm_obj:get_entry(10004)
    assert(#entry_list == 4)

    -- 删除数据 （使用 1个 关联 key）
    local res = orm_obj:delete_entry(10004)
    assert(res)

    --应该没有条数据
    local entry_list = orm_obj:get_entry(10004)
    assert(#entry_list == 0)

    --10005应该还存在
    local entry_list = orm_obj:get_entry(10005)
    assert(#entry_list == 1)

    delete_table()
end

--测试本地缓存
local function test_cache_entry()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(500, 100) --缓存5秒
    :builder(adapter)

    --创建entry 建立缓存 
    local entry_list = orm_obj:create_entry({player_id = 10001, role_id = 1, sex = 1})
    local entry = assert(entry_list[1])

    local get_entry_list = orm_obj:get_entry(10001)
    local get_entry = assert(entry_list[1])

    assert(entry == get_entry) --是同一个表
    skynet.sleep(600)

    --缓存过期
    local gg_entry_list,is_cache = orm_obj:get_entry(10001)
    local gg_entry = assert(gg_entry_list[1])
    assert(not is_cache)

    assert(entry ~= gg_entry) --不是同一个表

    --查询建立了缓存，再次查询应命中缓存
    local reget_entry_list,is_cache = orm_obj:get_entry(10001)
    local reget_entry = assert(reget_entry_list[1])

    assert(gg_entry == reget_entry)
    assert(is_cache)

    skynet.sleep(300)
    --查询延迟缓存时间 重置为5秒
    local rr_list = orm_obj:get_entry(10001)
    skynet.sleep(300)
    local rrr_list,is_cache = orm_obj:get_entry(10001)
    local rrr_entry = assert(rrr_list[1])
    assert(rrr_entry == reget_entry)
    assert(is_cache)

    -- 多条数据命中缓存
    local entry_list = orm_obj:create_entry(
        {player_id = 10002, role_id = 1, sex = 1},
        {player_id = 10002, role_id = 2, sex = 1},
        {player_id = 10002, role_id = 3, sex = 1},
        {player_id = 10002, role_id = 1, sex = 2},
        {player_id = 10002, role_id = 2, sex = 2},
        {player_id = 10002, role_id = 3, sex = 2},
        {player_id = 10003, role_id = 1, sex = 1},
        {player_id = 10003, role_id = 2, sex = 1},
        {player_id = 10003, role_id = 3, sex = 1},
        {player_id = 10003, role_id = 1, sex = 2},
        {player_id = 10003, role_id = 2, sex = 2},
        {player_id = 10003, role_id = 3, sex = 2}
    )

    --两个关联key
    local get_entry_list = orm_obj:get_entry(10002, 1)
    assert(entry_list[1] == get_entry_list[1])
    assert(entry_list[4] == get_entry_list[2])

    --1个关联key
    local gg_entry_list = orm_obj:get_entry(10002)
    assert(entry_list[1] == gg_entry_list[1])

    -- 多条数据中 有数据缓存过期查询应重拉数据
    skynet.sleep(600)
    --两个关联key
    local ggg_entry_list = orm_obj:get_entry(10002, 1)

    skynet.sleep(300)
    orm_obj:get_entry(10002, 1, 1) --保活一条数据
    skynet.sleep(300) --3秒后过期1条数据

    local gggg_entry_list,is_cache = orm_obj:get_entry(10002, 1) --拉取新的
    --1因为缓存还在 2缓存不在
    assert(ggg_entry_list[1] == gggg_entry_list[1])
    assert(ggg_entry_list[2] ~= gggg_entry_list[2])
    assert(not is_cache)

    skynet.sleep(600)
    --1个关联key
    local ggg_entry_list = orm_obj:get_entry(10002)
    skynet.sleep(300)
    orm_obj:get_entry(10002, 1, 1) --保活一条数据

    skynet.sleep(300) --3秒后过期5条数据
    local gggg_entry_list,is_cache = orm_obj:get_entry(10002) --拉取新的
    assert(ggg_entry_list[1] == gggg_entry_list[1])
    assert(ggg_entry_list[2] ~= gggg_entry_list[2])
    assert(not is_cache)

    --删除数据后拿取关联多条，应命中缓存
    local entry_list = orm_obj:get_entry(10003)
    orm_obj:delete_entry(10003, 3, 2)
    local gg_entry_list,is_cache = orm_obj:get_entry(10003)
    assert(is_cache)
    
    delete_table()
end

--测试定期自动保存数据
local function test_inval_save()
    delete_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(500,100)   --1保存一次
    :builder(adapter)

    -- 自动保存数据
    local entry_list = orm_obj:create_entry(
        {player_id = 10002, role_id = 1, sex = 1},
        {player_id = 10002, role_id = 2, sex = 1},
        {player_id = 10002, role_id = 3, sex = 1},
        {player_id = 10002, role_id = 1, sex = 2},
        {player_id = 10002, role_id = 2, sex = 2},
        {player_id = 10002, role_id = 3, sex = 2},
        {player_id = 10003, role_id = 1, sex = 1},
        {player_id = 10003, role_id = 2, sex = 1},
        {player_id = 10003, role_id = 3, sex = 1},
        {player_id = 10003, role_id = 1, sex = 2},
        {player_id = 10003, role_id = 2, sex = 2},
        {player_id = 10003, role_id = 3, sex = 2}
    )

    for i,entry in ipairs(entry_list) do
        entry:set("email", "emailssss")
    end

    skynet.sleep(1000)

    local entry_list = orm_obj:get_entry(10002)
    for i,entry in ipairs(entry_list) do
        local email = entry:get("email")
        assert(email == "emailssss")
    end

    delete_table()
end

--测试定期保存数据，数据库挂了之后再启动，数据应该还能落地
local function test_sql_over()
    delete_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(500,500)   --5秒保存一次
    :builder(adapter)

    -- 自动保存数据
    local entry_list = orm_obj:create_entry(
        {player_id = 10002, role_id = 1, sex = 1},
        {player_id = 10002, role_id = 2, sex = 1},
        {player_id = 10002, role_id = 3, sex = 1},
        {player_id = 10002, role_id = 1, sex = 2},
        {player_id = 10002, role_id = 2, sex = 2},
        {player_id = 10002, role_id = 3, sex = 2},
        {player_id = 10003, role_id = 1, sex = 1},
        {player_id = 10003, role_id = 2, sex = 1},
        {player_id = 10003, role_id = 3, sex = 1},
        {player_id = 10003, role_id = 1, sex = 2},
        {player_id = 10003, role_id = 2, sex = 2},
        {player_id = 10003, role_id = 3, sex = 2}
    )

    for i,entry in ipairs(entry_list) do
        entry:set("email", "emailssss")
    end

    --杀掉数据库
    os.execute("pkill mongod")
    log.info("杀掉数据库》》》》》》》》》》》》》")

    skynet.sleep(6000)

    os.execute("systemctl start mongod")
    log.info("启动数据库》》》》》》》》》》》》》")

    --等待缓存过期
    log.info("等待缓存过期》》》》》》》》》》》》》")
    skynet.sleep(1000)
    log.info("缓存过期》》》》》》》》》》》》》")

    local entry_list = orm_obj:get_entry(10002)
    for i,entry in ipairs(entry_list) do
        local email = entry:get("email")
        assert(email == "emailssss")
    end
    log.info("保存成功》》》》》》》》》》》》》")
    delete_table()
end

--测试对象没用后的定时器清除
local function test_over_clear_time()
    delete_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(500,500)   --5秒保存一次
    :builder(adapter)

    local time_obj = orm_obj._time_obj
    orm_obj = nil
 
    collectgarbage("collect")
    collectgarbage("collect")
    assert(time_obj.is_cancel == true)

    delete_table()
end

--测试缓存不过期
local function test_permanent()
    delete_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(0,500)   --5秒保存一次
    :builder(adapter)

    local entry_list = orm_obj:create_entry({
        player_id = 10001,
        role_id = 1,
        sex = 1
    })
    local entry = entry_list[1]

    skynet.sleep(1)

    local get_entry_List = orm_obj:get_entry(10001)
    local g_entry = get_entry_List[1]

    assert(entry == g_entry)

    delete_table()
end

--测试查询所有数据
local function test_get_all()
    delete_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(500,500)   --5秒保存一次
    :builder(adapter)

    local entry_list = orm_obj:create_entry(
        {player_id = 10002, role_id = 1, sex = 1},
        {player_id = 10002, role_id = 2, sex = 1},
        {player_id = 10002, role_id = 3, sex = 1},
        {player_id = 10002, role_id = 1, sex = 2},
        {player_id = 10002, role_id = 2, sex = 2},
        {player_id = 10002, role_id = 3, sex = 2},
        {player_id = 10003, role_id = 1, sex = 1},
        {player_id = 10003, role_id = 2, sex = 1},
        {player_id = 10003, role_id = 3, sex = 1},
        {player_id = 10003, role_id = 1, sex = 2},
        {player_id = 10003, role_id = 2, sex = 2},
        {player_id = 10003, role_id = 3, sex = 2}
    )

    local get_entry_list,is_cache = orm_obj:get_all_entry()
    assert(not is_cache and #get_entry_list == #entry_list)--首次查询，不确定缓存数量与实际数量是否一致

    local get_entry_list,is_cache = orm_obj:get_all_entry()
    assert(is_cache and #get_entry_list == #entry_list)--首次查询，第二次查询应命中缓存

    skynet.sleep(300)

    local get_entry_list,is_cache = orm_obj:get_entry(10002) --保活
    assert(not is_cache)
    skynet.sleep(300)
    
    assert(orm_obj._key_cache_count == 6 and orm_obj._key_cache_total_count == nil)
    local get_entry_list,is_cache = orm_obj:get_all_entry()
    assert(not is_cache)
    assert(orm_obj._key_cache_count == 12 and orm_obj._key_cache_total_count == 12)

    orm_obj:delete_entry(10002, 1, 1)
    assert(orm_obj._key_cache_count == 11 and orm_obj._key_cache_total_count == 11)

    orm_obj:create_entry({player_id = 10004, role_id = 3, sex = 2})
    assert(orm_obj._key_cache_count == 12 and orm_obj._key_cache_total_count == 12)
    delete_table()
end

--测试删除所有数据
local function test_delete_all()
    delete_table()
    local adapter = ormadapter_mongo:new("admin")
    local orm_obj = ormtable:new("t_player")
    :int64("player_id")
    :int64("role_id")
    :int8("sex")
    :string32("nickname")
    :string64("email")
    :uint8("sex1")
    :set_keys("player_id","role_id","sex")
    :set_cache(500,500)   --5秒保存一次
    :builder(adapter)

    local entry_list = orm_obj:create_entry(
        {player_id = 10002, role_id = 1, sex = 1},
        {player_id = 10002, role_id = 2, sex = 1},
        {player_id = 10002, role_id = 3, sex = 1},
        {player_id = 10002, role_id = 1, sex = 2},
        {player_id = 10002, role_id = 2, sex = 2},
        {player_id = 10002, role_id = 3, sex = 2},
        {player_id = 10003, role_id = 1, sex = 1},
        {player_id = 10003, role_id = 2, sex = 1},
        {player_id = 10003, role_id = 3, sex = 1},
        {player_id = 10003, role_id = 1, sex = 2},
        {player_id = 10003, role_id = 2, sex = 2},
        {player_id = 10003, role_id = 3, sex = 2}
    )

    orm_obj:delete_all_entry()
    assert(orm_obj._key_cache_count == 0 and orm_obj._key_cache_total_count == 0)

    local entry_list = orm_obj:get_all_entry()
    assert(#entry_list == 0)

    local entry_list = orm_obj:create_entry({player_id = 10002, role_id = 1, sex = 1})
    assert(orm_obj._key_cache_count == 1 and orm_obj._key_cache_total_count == 1)

    local entry_list = orm_obj:get_all_entry()
    assert(#entry_list == 1)

    delete_table()
end

function CMD.start()
    skynet.fork(function()
        log.info("test start >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        log.info("test_create_table>>>>>")
        test_create_table(true)
        log.info("test_alter_table>>>>>")
        test_alter_table()
        log.info("test_create_entry>>>>>")
        test_create_entry()
        log.info("test_select_entry>>>>>")
        test_select_entry()
        log.info("test_save_entry>>>>>")
        test_save_entry()
        log.info("test_delete_entry>>>>>")
        test_delete_entry()
        log.info("test_cache_entry>>>>>")
        test_cache_entry()
        log.info("test_inval_save>>>>>")
        test_inval_save()
        log.info("test_sql_over>>>>>")
        test_sql_over()
        log.info("test_over_clear_time>>>>>")
        test_over_clear_time()
        log.info("test_permanent>>>>>")
        test_permanent()
        log.info("test_get_all>>>>>")
        test_get_all()
        log.info("test_delete_all>>>>>")
        test_delete_all()
        log.info("test over >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    end)
    return true
end

function CMD.exit()
    return true
end

return CMD