local o={
p=print,pc=pcall,t=type,n=next,
g=getrawmetatable,dm=debug.getmetatable,
di=debug.getinfo,du=debug.getupvalues,
ic=iscclosure,ncc=newcclosure,
rg=rawget,rs=rawset,re=rawequal,
sm=setmetatable,sel=select,
game=game,dbg=debug
}

local function check(f)
	local a,b=o.pc(o.ic,f)
	local c,d=o.pc(o.di,f)
	return a and c and o.t(d)=="table" and b==(d.what=="C")
end

local function test()
	local s=0
	local fs={
		o.rg,o.rs,o.re,o.n,o.pc,
		o.t,o.di,o.du,o.dm,o.g,
		o.di,o.ic,o.ncc,o.w
	}

	for _,f in o.n,fs do
		if not check(f) then s+=1 end
	end

	local a,b={},{}
	local function capture()
		return a,b
	end

	local ok,u=o.pc(o.du,capture)
	local fa,fb=false,false

	if ok and o.t(u)=="table" then
		for _,v in o.n,u do
			if o.re(v,a) then fa=true end
			if o.re(v,b) then fb=true end
		end
	end

	if not fa or not fb then s+=3 end

	local marker={}
	local wrapped=o.ncc(function(...)
		return marker,o.sel("#",...),...
	end)

	local iok,ic=o.pc(o.ic,wrapped)
	local dok,info=o.pc(o.di,wrapped)
	local rok,r1,r2,r3,r4,r5=o.pc(wrapped,marker,nil,41)

	if not iok or not ic
		or not dok or o.t(info)~="table"
		or info.what~="C"
		or not rok
		or not o.re(r1,marker)
		or r2~=3
		or not o.re(r3,marker)
		or r4~=nil
		or r5~=41 then
		s+=4
	end

	local reads,writes=0,0
	local proxy=o.sm({},{
		__index=function()
			reads+=1
			return a
		end,
		__newindex=function()
			writes+=1
		end
	})

	local x=proxy.test
	local y=o.rg(proxy,"test")
	o.rs(proxy,"test",b)
	local z=proxy.test
	local k,v=o.n(proxy)

	if not o.re(x,a) or y~=nil
		or not o.re(z,b)
		or reads~=1 or writes~=0
		or k~="test" or not o.re(v,b) then
		s+=3
	end

	local m1ok,m1=o.pc(o.g,o.game)
	local m2ok,m2=o.pc(o.dm,o.game)

	if not m1ok or not m2ok
		or o.t(m1)~="table"
		or not o.re(m1,m2) then
		s+=4
	else
		for _,name in o.n,{"__index","__newindex","__namecall"} do
			local f=o.rg(m1,name)
			if f~=nil and o.t(f)=="function" and not check(f) then
				s+=2
			end
		end
	end

	if getrawmetatable~=o.g
		or rawget~=o.rg
		or rawset~=o.rs
		or rawequal~=o.re
		or debug~=o.dbg then
		s+=3
	end

	return s
end

local ok,result=o.pc(test)

if not ok or result>=5 then
	o.p("dtc")
else
	o.p("ud")
end
