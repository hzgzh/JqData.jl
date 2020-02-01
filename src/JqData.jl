module JqData


import JSON,HTTP
using DataFrames,CSV

export get_token,get_current_token,get_query_count,get_security_info
export get_all_securities,get_index_stocks,get_margincash_stocks,get_marginsec_stocks
export get_locked_share,get_locked_shares,get_index_stocks,get_index_weights
export get_industries,get_industry,get_industry_stocks
export get_concepts,get_concepts
export get_trade_days,get_all_trade_days
export get_mtss,get_money_flow
export get_billboard_list,get_future_contracts
export get_dominant_future,get_fund_info,get_current_tick
export get_current_ticks,get_extras,get_price,get_price_period
export get_ticks,get_ticks_period,get_factor_values,run_query
export get_fundamentals,get_all_factors,get_pause_stocks,get_alpha101,get_alpha191
export get_fq_factor,get_current_price,get_call_auction

url="https://dataapi.joinquant.com/apis"

function get_token()
    body=Dict("method"=>"get_token","mob"=>"13588711815","pwd"=>"720216")
    body=JSON.json(body)
    response=HTTP.post(url,"",body)
    String(response.body)
end

function get_current_token()
    body=Dict("method"=>"get_current_token","mob"=>"13588711815","pwd"=>"720216")
    body=JSON.json(body)
    response=HTTP.post(url,"",body)
    String(response.body)
    
end
"""
get_query_count - 获取查询剩余条数
查询剩余条数

{
    "method": "get_query_count",
    "token":"5b6a9ba7b0f572bb6c287e280ed"
}
100000
"""
function get_query_count()
    token=get_current_token()
    body=Dict("method"=>"get_query_count","token"=>token)
    response=HTTP.post(url,"",JSON.json(body))
    parse(Int,String(response.body))
end

function get_security_info(code)
    token=get_current_token()
    body=Dict("method"=>"get_security_info","token"=>token,"code"=>code)
    dataframe(body)
end


function dataframe(body)
    
    body=JSON.json(body)
    res=HTTP.post(url,"",body)
    res=String(res.body)
    DataFrame(CSV.File(IOBuffer(res)))
end
"""
get_price / get_bars - 获取指定时间周期的行情数据
获取各种时间周期的bar数据，bar的分割方式与主流股票软件相同， 同时还支持返回当前时刻所在 bar 的数据。get_price 与 get_bars 合并为一个函数

参数：

code: 证券代码
count: 大于0的整数，表示获取bar的条数，不能超过5000
unit: bar的时间单位, 支持如下周期：1m, 5m, 15m, 30m, 60m, 120m, 1d, 1w, 1M。其中m表示分钟，d表示天，w表示周，M表示月
end_date：查询的截止时间，默认是今天
fq_ref_date：复权基准日期，该参数为空时返回不复权数据
{
    "method": "get_price",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "600000.XSHG",
    "count": 10,
    "unit": "1d",
    "end_date": "2018-07-21",
    "fq_ref_date": "2018-07-21"
}
返回：

date: 日期
open: 开盘价
close: 收盘价
high: 最高价
low: 最低价
volume: 成交量
money: 成交额
当unit为1d时，包含以下返回值:
paused: 是否停牌，0 正常；1 停牌
high_limit: 涨停价
low_limit: 跌停价
avg: 当天均价
pre_close：前收价
当code为期货和期权时，包含以下返回值:
open_interest 持仓量
date,open,close,high,low,volume,money,paused,high_limit,low_limit,avg,pre_close
2018-07-09,9.27,9.50,9.53,9.27,22407527,212109327.00,0,10.20,8.34,9.47,9.27
2018-07-10,9.51,9.47,9.55,9.40,12534270,118668133.00,0,10.45,8.55,9.47,9.50
"""
function get_price(code;unit="1d",count=10,end_date="",fq_ref_date="")
    token=get_token()
    body=Dict(
        "method"=>"get_price",
        "token"=>token,
        "code"=>code,
        "unit"=>unit,
        "count"=>count,
        "end_date"=>end_date,
        "fq_ref_date"=>fq_ref_date
    )
    dataframe(body)
end

function get_all_securities(date)
    token=get_token()
    body=Dict(
        "method"=>"get_all_securities",
        "token"=>token,
        "code"=>"stock",
        "date"=>date        
    )
    dataframe(body)
end
"""
获取一个指数给定日期在平台可交易的成分股列表

参数:

code: 指数代码
date: 查询日期
{
    "method": "get_index_stocks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000300.XSHG",
    "date": "2019-01-09"
}
返回:

股票代码
000001.XSHE
000002.XSHE
"""
function get_index_stocks(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_index_stocks",
        "token"=>token,
        "code"=>code,
        "date"=>date        
    )
    dataframe(body)
end

"""
get_margincash_stocks - 获取融资标的列表
参数:

date: 查询日期，默认为前一交易日
{
    "method": "get_margincash_stocks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "date": "2018-07-02"
}
返回：

返回指定日期上交所、深交所披露的的可融资标的列表
000001.XSHE
000002.XSHE
"""
function get_margincash_stocks(date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_margincash_stocks",
        "token"=>token,
         "date"=>date        
    )
    dataframe(body)
end

"""
get_marginsec_stocks - 获取融券标的列表
参数:

date: 查询日期，默认为前一交易日
{
    "method": "get_marginsec_stocks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "date": "2018-08-02"
}
返回：

返回指定日期上交所、深交所披露的的可融券标的列表
000001.XSHE
000002.XSHE
"""
function get_marginsec_stocks(date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_marginsec_stocks",
        "token"=>token,
         "date"=>date        
    )
    dataframe(body)
end

"""
get_locked_shares - 获取限售解禁数据
获取指定日期区间内的限售解禁数据

参数：

code: 股票代码
date: 开始日期
end_date: 结束日期
{
    "method": "get_locked_shares",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "600000.XSHG",
    "date": "2010-09-29",
    "end_date": "2018-09-29"
}
返回：

day: 解禁日期
code: 股票代码
num: 解禁股数
rate1: 解禁股数/总股本
rate2: 解禁股数/总流通股本
day,code,num,rate1,rate2
2010-09-29,600000.XSHG,1175406872.0000,0.1024,0.1141
2015-10-14,600000.XSHG,3730694283.0000,0.2000,0.2500
"""
function get_locked_share(code,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_locked_shares",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date       
    )
    dataframe(body)
end

"""
get_index_weights - 获取指数成份股权重（月度）
获取指数成份股给定日期的权重数据，每月更新一次

参数：

code: 代表指数的标准形式代码， 形式：指数代码.交易所代码，例如"000001.XSHG"。
date: 查询权重信息的日期，形式："%Y-%m-%d"，例如"2018-05-03"；
{
    "method": "get_index_weights",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000300.XSHG",
    "date": "2018-01-09"
}
返回：

code: 指数代码
display_name: 股票名称
date: 日期
weight: 权重
code,display_name,date,weight
000001.XSHE,平安银行,2018-01-09,0.9730
000002.XSHE,万科A,2018-01-09,1.2870
"""
function get_index_weights(code,display_name,date,weight)
    token=get_current_token()
    body=Dict(
        "method"=>"get_index_weights",
        "token"=>token,
        "code"=>code,
        "display_name"=>display_name,
        "date"=>date,
        "weight"=>weight       
    )
    dataframe(body)
end

"""
get_industries - 获取行业列表
按照行业分类获取行业列表

参数：

code：行业代码
sw_l1: 申万一级行业
sw_l2: 申万二级行业
sw_l3: 申万三级行业
jq_l1: 聚宽一级行业
jq_l2: 聚宽二级行业
zjw: 证监会行业
{
    "method": "get_industries",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "sw_l3"
}
返回：

index: 行业代码
name: 行业名称
start_date: 开始日期
index,name,start_date
850111,种子生产III,2014-02-21
850112,粮食种植III,2014-02-21
"""
function get_industries(code)
    token=get_current_token()
    body=Dict(
        "method"=>"get_industries",
        "token"=>token,
        "code"=>code,
    )
    dataframe(body)
end

"""
get_industry - 查询股票所属行业
查询股票所属行业

参数：

code：证券代码
date：查询的日期
{
    "method": "get_industry",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000011.XSHE",
    "date": "2018-12-01"
}
返回：

industry：一级行业代码
industry_code：二级行业代码
industry_name：行业名称
industry,industry_code,industry_name
jq_l1,HY011,房地产指数
jq_l2,HY509,房地产开发指数
sw_l1,801180,房地产I
"""
function get_industry(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_industry",
        "token"=>token,
        "code"=>code,
        "date"=>date
    )
    dataframe(body)
end

"""
get_industry_stocks - 获取行业成份股
获取在给定日期一个行业的所有股票

参数：

code: 行业编码
date: 查询日期
{
    "method": "get_industry_stocks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "HY007",
    "date": "2016-03-29"
}
返回：

返回股票代码的list
000001.XSHE
000002.XSHE
"""
function get_industry_stocks(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_industry_stocks",
        "token"=>token,
        "code"=>code,
        "date"=>date
    )
    dataframe(body)
end

"""
get_concepts - 获取概念列表
获取概念板块列表

{
    "method": "get_concepts"
    "token": "5b6a9ba7b0f572bb6c287e280ed",
}
返回：

code: 概念代码
name: 概念名称
start_date: 开始日期
code,name,start_date
GN001,参股金融,2013-12-31
GN028,智能电网,2013-12-31
"""

function get_concepts()
    token=get_current_token()
    body=Dict(
        "method"=>"get_concepts",
        "token"=>token,
    )
    dataframe(body)
end

"""
get_concept_stocks - 获取概念成份股
获取在给定日期一个概念板块的所有股票

参数：

code: 概念板块编码
date: 查询日期,
{
    "method": "get_concept_stocks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "GN036",
    "date": "2016-12-19"
}
返回：

股票代码
000791.XSHE
000836.XSHE
"""
function get_concept_stocks(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_concept_stocks",
        "token"=>token,
        "code"=>code,
        "date"=>date
    )
    dataframe(body)
end

"""
get_trade_days - 获取指定范围交易日
获取指定日期范围内的所有交易日

参数：

date: 开始日期
end_date: 结束日期
{
    "method": "get_trade_days",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "date": "2018-10-09",
    "end_date": "2018-11-18"
}
返回：

交易日日期
2018-10-09
2018-10-10
"""
function get_trade_days(date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_trade_days",
        "token"=>token,
        "date"=>date,
        "end_date"=>end_date
    )
    dataframe(body)
end

"""
get_all_trade_days - 获取所有交易日
{
    "method": "get_all_trade_days"
    "token": "5b6a9ba7b0f572bb6c287e280ed",
}
2005-01-04
2005-01-05
"""
function get_all_trade_days()
    token=get_current_token()
    body=Dict(
        "method"=>"get_all_trade_days",
        "token"=>token,
    )
    dataframe(body)
end

"""
get_mtss - 获取融资融券信息
获取一只股票在一个时间段内的融资融券信息

参数：

code: 股票代码
date: 开始日期
end_date: 结束日期
{
    "method": "get_mtss",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE",
    "date": "2016-01-04",
    "end_date": "2016-04-01"
}
返回：

date: 日期
sec_code: 股票代码
fin_value: 融资余额(元）
fin_buy_value: 融资买入额（元）
fin_refund_value: 融资偿还额（元）
sec_value: 融券余量（股）
sec_sell_value: 融券卖出量（股）
sec_refund_value: 融券偿还量（股）
fin_sec_value: 融资融券余额（元）
date,sec_code,fin_value,fin_buy_value,fin_refund_value,sec_value,sec_sell_value,sec_refund_value,fin_sec_value
2016-01-04,000001.XSHE,3472611852,152129217,169414153,594640,184100,317900,3479349123
2016-01-05,000001.XSHE,3439316930,143615276,176910198,584540,20800,30900,3445980686
"""
function get_mtss(code,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_mtss",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date
    )
    dataframe(body)
end

"""
get_money_flow - 获取资金流信息
获取一只股票在一个时间段内的资金流向数据，仅包含股票数据，不可用于获取期货数据

参数：

code: 股票代码
date: 开始日期
end_date: 结束日期
{
    "method": "get_money_flow",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE",
    "date": "2016-02-01",
    "end_date": "2016-02-04"
}
返回：

date: 日期
sec_code: 股票代码
change_pct: 涨跌幅(%)
net_amount_main: 主力净额(万): 主力净额 = 超大单净额 + 大单净额
net_pct_main: 主力净占比(%): 主力净占比 = 主力净额 / 成交额
net_amount_xl: 超大单净额(万): 超大单：大于等于50万股或者100万元的成交单
net_pct_xl: 超大单净占比(%): 超大单净占比 = 超大单净额 / 成交额
net_amount_l: 大单净额(万): 大单：大于等于10万股或者20万元且小于50万股或者100万元的成交单
net_pct_l: 大单净占比(%): 大单净占比 = 大单净额 / 成交额
net_amount_m: 中单净额(万): 中单：大于等于2万股或者4万元且小于10万股或者20万元的成交单
net_pct_m: 中单净占比(%): 中单净占比 = 中单净额 / 成交额
net_amount_s: 小单净额(万): 小单：小于2万股或者4万元的成交单
net_pct_s: 小单净占比(%): 小单净占比 = 小单净额 / 成交额
date,sec_code,change_pct,net_amount_main,net_pct_main,net_amount_xl,net_pct_xl,net_amount_l,net_pct_l,net_amount_m,net_pct_m,net_amount_s,net_pct_s
2016-02-01,000001.XSHE,-2.00,-6940.54,-16.82,-5296.92,-12.84,-1643.63,-3.98,3782.95,9.17,3157.59,7.65
2016-02-02,000001.XSHE,1.53,1375.48,3.74,2235.87,6.09,-860.39,-2.34,-194.21,-0.53,-1181.27,-3.22
"""
function get_money_flow(code,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_money_flow",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date
    )
    dataframe(body)
end

"""
get_billboard_list - 获取龙虎榜数据
获取指定日期区间内的龙虎榜数据

参数：

code: 股票代码
date: 开始日期
end_date: 结束日期
{
    "method": "get_billboard_list",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE",
    "date": "2016-08-01",
    "end_date": "2018-11-29"
}
返回：

code: 股票代码
day: 日期
direction: ALL 表示『汇总』，SELL 表示『卖』，BUY 表示『买』
abnormal_code: 异常波动类型
abnormal_name: 异常波动名称
sales_depart_name: 营业部名称
rank: 0 表示汇总， 1~5 表示买一到买五， 6~10 表示卖一到卖五
buy_value: 买入金额
buy_rate: 买入金额占比(买入金额/市场总成交额)
sell_value: 卖出金额
sell_rate: 卖出金额占比(卖出金额/市场总成交额)
net_value: 净额(买入金额 - 卖出金额)
amount: 市场总成交额
code,day,direction,rank,abnormal_code,abnormal_name,sales_depart_name,buy_value,buy_rate,sell_value,sell_rate,total_value,net_value,amount
000001.XSHE,2017-07-11,ALL,0,106001,涨幅偏离值达7%的证券,,495288143.0000,0.1289,305812442.0000,0.0796,801100585.0000,189475701.0000,3842010171.2900
000001.XSHE,2017-07-11,BUY,1,106001,涨幅偏离值达7%的证券,中信证券股份有限公司上海古北路证券营业部,134111708
"""
function get_billboard_list(code,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_billboard_list",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date
    )
    dataframe(body)
end

"""
get_future_contracts - 获取期货可交易合约列表
获取某期货品种在指定日期下的可交易合约标的列表

参数：

code: 期货合约品种，如 AG (白银)
date: 指定日期
{
    "method": "get_future_contracts",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "AU",
    "date": "2017-01-05"
}
返回：

某一期货品种在指定日期下的可交易合约标的列表
AU1701.XSGE
AU1702.XSGE
"""
function get_future_contracts(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_future_contracts",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        
    )
    dataframe(body)
end

"""
get_dominant_future - 获取主力合约对应的标的
参数：

code: 期货合约品种，如 AG (白银)
date: 指定日期参数，获取历史上该日期的主力期货合约
{
    "method": "get_dominant_future",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "AU",
    "date": "2018-05-05"
}
返回：

主力合约对应的期货合约
AU1812.XSGE
"""
function get_dominant_future(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_dominant_future",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        
    )
    dataframe(body)
end

"""
get_fund_info - 基金基础信息数据接口
获取单个基金的基本信息

参数：

code: 基金代码
date: 查询日期， 默认日期是今天。
{
    "method": "get_fund_info",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "519223.OF",
    "date": "2018-12-01"
}
返回：

fund_name: 基金全称
fund_type: 基金类型
fund_establishment_day: 基金成立日
fund_manager: 基金管理人及基本信息
fund_management_fee: 基金管理费
fund_custodian_fee: 基金托管费
fund_status: 基金申购赎回状态
fund_size: 基金规模（季度）
fund_share: 基金份额（季度）
fund_asset_allocation_proportion: 基金资产配置比例（季度）
heavy_hold_stocks: 基金重仓股（季度）
heavy_hold_stocks_proportion: 基金重仓股占基金资产净值比例（季度）
heavy_hold_bond: 基金重仓债券（季度）
heavy_hold_bond_proportion: 基金重仓债券占基金资产净值比例（季度）
{
    "fund_name": "海富通欣荣灵活配置混合型证券投资基金C类",
    "fund_type": "混合型",
    "fund_establishment_day": "2016-09-22",
    "fund_manager": "海富通基金管理有限公司",
    "fund_management_fee": "",
    "fund_custodian_fee": "",
    "fund_status": "",
    "fund_size": "",
    "fund_share": 32345.96,
    "fund_asset_allocation_proportion": "",
    "heavy_hold_stocks": ["600519","601318","601398","000651","600887","600028","000338","600048","601939","000858"],
    "heavy_hold_stocks_proportion": 37.16,
    "heavy_hold_bond": ["111893625","018005","113014"],
    "heavy_hold_bond_proportion": 13.209999999999999
}
"""
function get_fund_info(code,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_fund_info",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        
    )
    dataframe(body)
end

"""
get_current_tick - 获取最新的 tick 数据
参数：

code: 标的代码， 支持股票、指数、基金、期货等。 不可以使用主力合约和指数合约代码。
{
    "method": "get_current_tick",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE"
}
返回：

time: 时间
current: 当前价
high: 截至到当前时刻的日内最高价
low: 截至到当前时刻的日内最低价
volume: 累计成交量
money: 累计成交额
position: 持仓量，期货使用
a1_v~a5_v: 五档卖量
a1_p~a5_p: 五档卖价
b1_v~b5_v: 五档买量
b1_p~b5_p: 五档买价
time,current,high,low,volume,money,position,a1_v,a2_v,a3_v,a4_v,a5_v,a1_p,a2_p,a3_p,a4_p,a5_p,b1_v,b2_v,b3_v,b4_v,b5_v,b1_p,b2_p,b3_p,b4_p,b5_p
20190129150003.000,11.0,11.07,10.77,82663110,904847854.07,,302833,195900,453000,437662,861700,1
"""
function get_current_tick(code)
    token=get_current_token()
    body=Dict(
        "method"=>"get_current_tick",
        "token"=>token,
        "code"=>code,
        
        
    )
    dataframe(body)
end

"""
get_current_ticks - 获取多标的最新的 tick 数据
参数：

code: 标的代码， 多个标的使用,分隔。每次请求的标的必须是相同类型。标的类型包括： 股票、指数、场内基金、期货、期权
{
    "method": "get_current_ticks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE,000002.XSHE,000006.XSHE"
}
返回：

code: 标的代码
time: 时间
current: 当前价
high: 截至到当前时刻的日内最高价
low: 截至到当前时刻的日内最低价
volume: 累计成交量
money: 累计成交额
position: 持仓量，期货使用
a1_v~a5_v: 五档卖量
a1_p~a5_p: 五档卖价
b1_v~b5_v: 五档买量
b1_p~b5_p: 五档买价
code,time,current,high,low,volume,money,position,a1_v,a2_v,a3_v,a4_v,a5_v,a1_p,a2_p,a3_p,a4_p,a5_p,b1_v,b2_v,b3_v,b4_v,b5_v,b1_p,b2_p,b3_p,b4_p,b5_p
000001.XSHE,20190408113000.000,14.05,14.43,13.89,117052113,1666868688.81,,9200,600,9200,50641,71600,14.06,14.07,14.08,14.09,14.1,53900,21800,147100,94536,213900,14.05,14.04,14.03,14.02,14.01
000002.XSHE,20190408113000.000,31.58,32.8,31.54,42866139,1379238397.85,,700,9400,700,6700,1100,31.58
"""
function get_current_ticks(code)
    token=get_current_token()
    body=Dict(
        "method"=>"get_current_ticks",
        "token"=>token,
        "code"=>code,
        
        
    )
    dataframe(body)
end
"""
get_extras - 获取基金净值/期货结算价等
参数：

code: 证券代码
date: 开始日期
end_date: 结束日期
{
    "method": "get_extras",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE",
    "date": "2018-05-29",
    "end_date": "2018-07-06"
}
返回：

date: 日期
is_st: 是否是ST，是则返回 1，否则返回 0。股票使用
acc_net_value: 基金累计净值。基金使用
unit_net_value: 基金单位净值。基金使用
futures_sett_price: 期货结算价。期货使用
futures_positions: 期货持仓量。期货使用
adj_net_value: 场外基金的复权净值。场外基金使用
date,is_st
2018-05-29,0
2018-05-30,0
"""
function get_extras(code,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_extras",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date
        
    )
    dataframe(body)
end

"""
get_price_period / get_bars_period- 获取指定时间段的行情数据
指定开始时间date和结束时间end_date时间段，获取行情数据

参数：

code: 证券代码
unit: bar的时间单位, 支持如下周期：1m, 5m, 15m, 30m, 60m, 120m, 1d, 1w, 1M。其中m表示分钟，d表示天，w表示周，M表示月
date : 开始时间，不能为空，格式2018-07-03或2018-07-03 10:40:00，如果是2018-07-03则默认为2018-07-03 00:00:00
end_date：结束时间，不能为空，格式2018-07-03或2018-07-03 10:40:00，如果是2018-07-03则默认为2018-07-03 23:59:00
fq_ref_date：复权基准日期，该参数为空时返回不复权数据
注：当unit是1w或1M时，第一条数据是开始时间date所在的周或月的行情。当unit为分钟时，第一条数据是开始时间date所在的一个unit切片的行情。
最大获取1000个交易日数据

{
    "method": "get_price_period",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "600000.XSHG",
    "unit": "30m",
    "date": "2018-12-04 09:45:00",    
    "end_date": "2018-12-04 10:40:00",
    "fq_ref_date": "2018-12-18"
}
返回：

date: 日期
open: 开盘价
close: 收盘价
high: 最高价
low: 最低价
volume: 成交量
money: 成交额
当unit为1d时，包含以下返回值:
paused: 是否停牌，0 正常；1 停牌
high_limit: 涨停价
low_limit: 跌停价
当code为期货和期权时，包含以下返回值:
open_interest 持仓量
date,open,close,high,low,volume,money
2018-12-04 10:00,11.00,11.03,11.07,10.97,4302800,47472956.00
2018-12-04 10:30,11.04,11.04,11.06,10.98,3047800,33599476.00
"""
function get_price_period(code,unit,date,end_date,fq_ref_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_price_period",
        "token"=>token,
        "code"=>code,
        "unit"=>unit,
        "date"=>date,
        "end_date"=>end_date,
        "fq_ref_date"=>fq_ref_date
    )
    dataframe(body)
end

"""
get_ticks - 获取tick数据
股票部分， 支持 2010-01-01 至今的tick数据，提供买五卖五数据
期货部分， 支持 2010-01-01 至今的tick数据，提供买一卖一数据。 如果要获取主力合约的tick数据，可以先使用get_dominant_future获取主力合约对应的标的
期权部分，支持 2017-01-01 至今的tick数据，提供买五卖五数据

参数：

code: 证券代码
count: 取出指定时间区间内前多少条的tick数据，如不填count，则返回end_date一天内的全部tick
end_date: 结束日期，格式2018-07-03或2018-07-03 10:40:00
skip: 默认为true，过滤掉无成交变化的tick数据；
当skip=false时，返回的tick数据会保留从2019年6月25日以来无成交有盘口变化的tick数据。
由于期权成交频率低，所以建议请求期权数据时skip设为false
{
    "method": "get_ticks",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE",
    "count": 15,
    "end_date": "2018-07-03"
}
返回：

time: 时间
current: 当前价
high: 当日最高价
low: 当日最低价
volume: 累计成交量（手）
money: 累计成交额
position: 持仓量，期货使用
a1_v~a5_v: 五档卖量
a1_p~a5_p: 五档卖价
b1_v~b5_v: 五档买量
b1_p~b5_p: 五档买价
time,current,high,low,volume,money,a1_p,a1_v,a2_p,a2_v,a3_p,a3_v,a4_p,a4_v,a5_p,a5_v,b1_p,b1_v,b2_p,b2_v,b3_p,b3_v,b4_p,b4_v,b5_p,b5_v
2018-07-02 14:56:21,8.62,9.05,8.56,1280510.0,1128400132.0,8.62,5006.0,8.63,6549.0,8.64,417.0,8.65,466.0,8.66,816.0,8.61,1134.0,8.6,3960.0,8.59,2054.0,8.58,3171.0,8.57,1710.0
2018-07-02 14:56:24,8.62,9.05,8.56,1280663.0,1128531972.0,8.62,4934.0,8.63,6519.0,8.64,417.0,8.65,4
"""
function get_ticks(code,count,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_ticks",
        "token"=>token,
        "code"=>code,
        "count"=>count,
        "end_date"=>end_date
        
    )
    dataframe(body)
end

"""
get_ticks_period- 按时间段获取tick数据
股票部分， 支持 2010-01-01 至今的tick数据，提供买五卖五数据
期货部分， 支持 2010-01-01 至今的tick数据，提供买一卖一数据。 如果要获取主力合约的tick数据，可以先使用get_dominant_future获取主力合约对应的标的
期权部分，支持 2017-01-01 至今的tick数据，提供买五卖五数据

参数：

code: 证券代码
date: 开始时间，格式2018-07-03或2018-07-03 10:40:00
end_date: 结束时间，格式2018-07-03或2018-07-03 10:40:00
skip: 默认为true，过滤掉无成交变化的tick数据；
当skip=false时，返回的tick数据会保留从2019年6月25日以来无成交有盘口变化的tick数据。
注：
如果时间跨度太大、数据量太多则可能导致请求超时，所有请控制好data-end_date之间的间隔！

{
    "method": "get_ticks_period",
    "token":"5b6a9ba7b0f572bb6c287e280ed"
    "code": "CU1906.XSGE",
    "date": "2019-03-27 21:40:01",
    "end_date": "2019-03-28 09:40:04"
}
返回：

time: 时间
current: 当前价
high: 当日最高价
low: 当日最低价
volume: 累计成交量（手）
money: 累计成交额
position: 持仓量，期货使用
a1_v~a5_v: 五档卖量
a1_p~a5_p: 五档卖价
b1_v~b5_v: 五档买量
b1_p~b5_p: 五档买价
time,current,high,low,volume,money,position,a1_p,a1_v,b1_p,b1_v
2019-03-27 21:40:11,48480.0,48500.0,48430.0,5458.0,1322750300.0,128176.0,48480.0,8.0,48470.0,18.0
2019-03-27 21:40:11.500000,48480.0,48500.0,48430.0,5464.0,1324204700.0,128178.0,48490.0,39.0,484
"""
function get_ticks_period(code,date,end_date,skip=true)
    token=get_current_token()
    body=Dict(
        "method"=>"get_ticks_period",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date,
        "skip"=>skip
    )
    dataframe(body)
end

"""
get_factor_values - 聚宽因子库数据
获取因子值的 API，点击查看因子列表

参数：

code: 单只股票代码
columns: 因子名称，因子名称，多个因子用逗号分隔
date: 开始日期
end_date: 结束日期
{
    "method": "get_factor_values",
    "token":"5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE",
    "date": "2019-01-20",
    "end_date":"2019-02-07",
    "columns":"net_profit_ratio,cfo_to_ev"
}
返回：

date：日期
查询因子值
注：

为保证数据的连续性，所有数据基于后复权计算
为了防止单次返回数据时间过长，尽量较少查询的因子数和时间段
如果第一次请求超时，尝试重试
date,cfo_to_ev,net_profit_ratio
2019-01-21,0.009278,0.217480
2019-01-22,0.009281,0.217480
"""
function get_factor_values(code,columns,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_factor_values",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date,
        "columns"=>columns
    )
    dataframe(body)
end

"""
run_query - 模拟JQDataSDK的run_query方法
run_query api 是模拟了JQDataSDK run_query方法获取财务、宏观、期权等数据
可查询的数据内容请查看JQData文档

以查询上市公司分红送股（除权除息）数据为例：

参数：

table: 要查询的数据库和表名，格式为 database + . + tablename 如finance.STK_XR_XD
columns: 所查字段，为空时则查询所有字段，多个字段中间用,分隔。如id,company_id，columns不能有空格等特殊字符
conditions: 查询条件，可以为空，格式为report_date#>=#2006-12-01&report_date#<=#2006-12-31，条件内部#号分隔，格式： column # 判断符 # value，多个条件使用&号分隔，表示and，conditions不能有空格等特殊字符
count: 查询条数，count为空时默认1条，最多查询1000条
{
    "method": "run_query",
    "token":"5b6a9ba7b0f572bb6c287e280ed",
    "table":"finance.STK_XR_XD",
    "columns":"company_id,company_name,code,report_date",
    "conditions":"report_date#=#2006-12-01",
    "count":10
}
返回：

返回的结果顺序为生成时间的顺序
company_id,company_name,code,report_date
420600103,福建省青山纸业股份有限公司,600103.XSHG,2006-12-01
430000506,中润资源投资股份有限公司,000506.XSHE,2006-12-01
注：run_query api 只是简单地模拟了python的sqlalchemy.orm.query.Query方法，不能支持复杂的搜索。想要更好查询体验，可以使用JQDataSDK。
"""
function run_query(table,columns,conditions,count)
    token=get_current_token()
    body=Dict(
        "method"=>"run_query",
        "token"=>token,
        "table"=>table,
        "columns"=>columns,
        "conditions"=>conditions,
        "count"=>count
    )
    dataframe(body)
end

"""
get_fundamentals - 获取基本财务数据
查询股票的市值数据、资产负债数据、现金流数据、利润数据、财务指标数据. 详情通过财务数据列表查看!

参数：

table: 要查询表名，可选项balance，income，cash_flow，indicator，valuation，bank_indicator，security_indicator，insurance_indicator
columns: 所查字段，为空时则查询所有字段，多个字段中间用,分隔。如id,company_id，columns不能有空格等特殊字符
code: 证券代码，多个标的使用,分隔
date: 查询日期2019-03-04或者年度2018或者季度2018q1 2018q2 2018q3 2018q4
count: 查询条数，最多查询1000条。不填count时按date查询
{
    "method": "get_fundamentals",
    "token":"5b6a9ba7b0f572bb6c287e280ed"
    "table":"valuation",
    "columns":"code,day,pb_ratio,ps_ratio,capitalization,circulating_cap",
    "code":"000001.XSHE,000002.XSHE",
    "date":"2016-12-04",
    "count": 4
}
返回：

返回的结果按日期顺序
code,day,pb_ratio,ps_ratio,capitalization,circulating_cap
000001.XSHE,2016-12-03,0.9198,1.5328,1717041.1250,1463118.0000
000001.XSHE,2016-12-04,0.9198,1.5328,1717041.1250,1463118.0000
000002.XSHE,2016-12-03,2.9081,1.2531,1103915.2500,970810.7500
000002.XSHE,2016-12-04,2.9081,1.2531,1103915.2500,970810.7500
"""
function get_fundamentals(code,table,columns,date,count)
    token=get_current_token()
    body=Dict(
        "method"=>"run_query",
        "token"=>token,
        "code"=>code,
        "table"=>table,
        "columns"=>columns,
        "date"=>date,
        "count"=>count
    )
    dataframe(body)
end

"""
get_all_factors 获取聚宽因子库中所有因子的信息
获取聚宽因子库中所有因子的信息

{
    "method": "get_all_factors",
    "token":"5b6a9ba7b0f572bb6c287e280ed"
}
返回：

factor 因子代码
factor_intro 因子名称
category 因子分类
category_intro 分类名称
factor,factor_intro,category,category_intro
administration_expense_ttm,管理费用TTM,basics,基础科目及衍生类因子
asset_impairment_loss_ttm,资产减值损失TTM,basics,基础科目及衍生类因子
"""
function get_all_factors()
    token=get_current_token()
    body=Dict(
        "method"=>"get_all_factors",
        "token"=>token,
    )
    dataframe(body)
end

"""
get_pause_stocks 获取停牌股票列表
获取某日停牌股票列表

参数：

date 查询日期，date为空时默认为今天
{
    "method": "get_pause_stocks",
    "token":"5b6a9ba7b0f572bb6c287e280ed",
    "date": "2019-05-14"
}
返回：

股票代码列表
000029.XSHE
000333.XSHE
"""
function get_pause_stocks()
    token=get_current_token()
    body=Dict(
        "method"=>"get_pause_stocks",
        "token"=>token,
    )
    dataframe(body)
end

"""
get_alpha101 获取 Alpha 101 因子
因子来源： 根据 WorldQuant LLC 发表的论文 101 Formulaic Alphas 中给出的 101 个 Alphas 因子公式，我们将公式编写成了函数，方便大家使用。

详细介绍： 函数计算公式、API 调用方法，输入输出值详情请见:数据 - Alpha 101.

参数：

code: 标的代码， 多个标的使用,分隔。建议每次请求的标的都是相同类型。支持最多1000个标的查询
func_name: 查询函数名称，如alpha_001，alpha_002等
date: 查询日期
{
    "method": "get_alpha101",
    "token":"5b6a9ba7b0f572bb6c287e280ed",
    "code":"000001.XSHE,000002.XSHE,000004.XSHE",
    "func_name":"alpha_001",
    "date":"2018-04-24"
}
返回：

股票代码
因子值
code,alpha_001
000001.XSHE,0.17
000002.XSHE,0.17
000004.XSHE,-0.17
"""
function get_alpha101(code,func_name,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_alpha101",
        "token"=>token,
        "code"=>code,
        "func_name"=>func_name,
        "date"=>date
    )
    dataframe(body)
end

"""
get_alpha191 获取 Alpha 191 因子
因子来源： 根据国泰君安数量化专题研究报告 - 基于短周期价量特征的多因子选股体系给出了 191 个短周期交易型阿尔法因子。为了方便用户快速调用，我们将所有Alpha191因子基于股票的后复权价格做了完整的计算。用户只需要指定fq='post’即可获取全新计算的因子数据。

详细介绍： 函数计算公式、API 调用方法，输入输出值详情请见:数据 - Alpha 191.

参数：

code: 标的代码， 多个标的使用,分隔。建议每次请求的标的都是相同类型。支持最多1000个标的查询
func_name: 查询函数名称，如alpha_001，alpha_002等
date: 查询日期
{
    "method": "get_alpha191",
    "token":"5b6a9ba7b0f572bb6c287e280ed",
    "code":"000001.XSHE,000002.XSHE,000004.XSHE",
    "func_name":"alpha_003",
    "date":"2018-04-24"
}
返回：

股票代码
因子值
code,alpha_003
000001.XSHE,0.55000000
000002.XSHE,0.27000000
000004.XSHE,-0.17000000
"""
function get_alpha191(code,func_name,date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_alpha191",
        "token"=>token,
        "code"=>code,
        "func_name"=>func_name,
        "date"=>date
    )
    dataframe(body)
end

"""
get_fq_factor 获取股票和基金复权因子
根据交易时间获取股票和基金复权因子值
参数：

code: 单只标的代码
fq: 复权选项 - pre 前复权； post后复权
date: 开始日期
end_date: 结束日期
{
    "method": "get_fq_factor",
    "token":"5b6a9ba7b0f572bb6c287e280ed",
    "code":"000001.XSHE",
    "fq":"pre",
    "date":"2019-06-17",
    "end_date":"2019-07-17"
}
返回：

date: 对应交易日
标的因子值
date,000001.XSHE
2019-06-25,0.989576
2019-06-26,1.000000
"""
function get_fq_factor(code,fq,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_fq_factor",
        "token"=>token,
        "code"=>code,
        "fq"=>fq
        "end_date"=>end_date,
        "date"=>date
    )
    dataframe(body)
end

"""
get_current_price 获取标的当前价
获取标的的当期价，等同于最新tick中的当前价
参数：

code: 标的代码， 多个标的使用,分隔。建议每次请求的标的都是相同类型。
{
    "method": "get_current_price",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE,600600.XSHG"
}
返回：

code: 标的代码
current: 当前价格
code,current
000001.XSHE,13.35
600600.XSHG,42.4
"""
function get_current_price(code)
    token=get_current_token()
    body=Dict(
        "method"=>"get_current_price",
        "token"=>token,
        "code"=>code,
    )
    dataframe(body)
end

"""
get_call_auction 获取集合竞价时的tick数据
获取指定时间区间内集合竞价时的tick数据
参数：

code: 标的代码， 多个标的使用,分隔。支持最多100个标的查询。
date: 开始日期
end_date: 结束日期
{
    "method": "get_call_auction",
    "token": "5b6a9ba7b0f572bb6c287e280ed",
    "code": "000001.XSHE,000002.XSHE"
    "date":"2019-09-20",
    "end_date":"2019-09-23"
}
返回：

code: 标的代码
time 时间 datetime
current 当前价 float
volume 累计成交量（股）
money 累计成交额
a1_v~a5_v: 五档卖量
a1_p~a5_p: 五档卖价
b1_v~b5_v: 五档买量
b1_p~b5_p: 五档买价
code,time,current,volume,money,a1_v,a2_v,a3_v,a4_v,a5_v,a1_p,a2_p,a3_p,a4_p,a5_p,b1_v,b2_v,b3_v,b4_v,b5_v,b1_p,b2_p,b3_p,b4_p,b5_p
000001.XSHE,2019-09-20 09:25:03,14.9500,3917700,5856.9600,511751,55200,46700,471356,806000,14.9500,14.9600,14.9700,14.9800,14.9900,556400,229100,151400,179600,115500,14.9400,14.9300,14.9200,14.9100,14.9000
000002.XSHE,2019-09-20 09:25:03,26.8900,260700,701.0200,17280,16500,3700,1500,4700,26.8900,26.90
"""
function get_call_auction(code,date,end_date)
    token=get_current_token()
    body=Dict(
        "method"=>"get_call_aution",
        "token"=>token,
        "code"=>code,
        "date"=>date,
        "end_date"=>end_date
    )
    dataframe(body)
end



end # module
