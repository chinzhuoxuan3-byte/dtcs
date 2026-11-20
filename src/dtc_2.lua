local out,pc=print,pcall

local ok,result=pc(function()
	local c=coroutine
	local eq,rg,rs,nx,sm,er=rawequal,rawget,rawset,next,setmetatable,error
	local token,reply={},{}

	local co=c.create(function()
		local a,b,d,e=c.yield(token,nil,31,false)
		return a,token,b,d,e
	end)

	local a,y1,y2,y3,y4=c.resume(co)
	local s1=c.status(co)
	local b,r1,r2,r3,r4,r5=c.resume(co,reply,nil,47,false)
	local s2=c.status(co)

	local coOK=a and eq(y1,token) and y2==nil and y3==31 and y4==false
		and s1=="suspended"
		and b and eq(r1,reply) and eq(r2,token)
		and r3==nil and r4==47 and r5==false
		and s2=="dead"

	local hits=0
	local proxy={}
	sm(proxy,{
		__index=function()
			hits+=1
			return token
		end,
		__newindex=function(t,k,v)
			hits+=1
			rs(t,k,v)
		end
	})

	local x=proxy.missing
	local y=rg(proxy,"missing")
	proxy.saved=reply
	local z=rg(proxy,"saved")
	local k,v=nx(proxy)

	local metaOK=eq(x,token) and y==nil
		and eq(z,reply) and k=="saved"
		and eq(v,reply) and hits==2

	local success,value=pc(function()
		er(token,0)
	end)

	local errorOK=not success and eq(value,token)

	return coOK and metaOK and errorOK
end)

out(ok and result and "ud" or "dtc")
