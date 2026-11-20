local dbg=debug
local o={
g=getrawmetatable,
p=print,
ic=iscclosure,
di=dbg and dbg.getinfo,
du=dbg and dbg.getupvalues,
dm=dbg and dbg.getmetatable,
r=rawget,
t=type,
pc=pcall,
n=next,
w=task and task.wait,
game=game,
rg=rawget,
rs=rawset,
re=rawequal,
te=typeof,
ts=tostring,
tb=dbg and dbg.traceback,
ncc=newcclosure
}

local function q(f)
	local s=0
	if o.t(f)~="function" then return 6 end
	local a,b=o.pc(o.ic,f)
	if not a or not b then s+=3 end
	local c,u=o.pc(o.du,f)
	if not c then s+=1 elseif o.t(u)~="table" then s+=2 elseif o.n(u)~=nil then s+=2 end
	local e,i=o.pc(o.di,f)
	if not e or o.t(i)~="table" then s+=2 elseif i.what and i.what~="C" then s+=2 end
	return s
end

local function x()
	local s=0
	if iscclosure~=o.ic or debug~=dbg or (debug and debug.getinfo)~=o.di or (debug and debug.getupvalues)~=o.du or (debug and debug.getmetatable)~=o.dm or rawget~=o.rg or rawset~=o.rs or rawequal~=o.re or (debug and debug.traceback)~=o.tb or typeof~=o.te or tostring~=o.ts then
		s+=8
	end

	local a,m=o.pc(o.g,o.game)
	if not a or o.t(m)~="table" then return 12 end

	local b,m2=o.pc(o.g,o.game)
	if not b or m~=m2 then s+=4 end

	local r1,nn=o.pc(o.r,m,"__namecall")
	local r2,ni=o.pc(o.r,m,"__index")
	local r3,nni=o.pc(o.r,m,"__newindex")

	if not r1 or not r2 or not r3 then
		s+=6
	else
		s+=q(nn)+q(ni)+(nni and q(nni) or 0)
	end

	local ok3,dm=o.pc(o.dm,o.game)
	if not ok3 or dm~=m then s+=4 end

	local wok,wic=o.pc(o.ic,o.w)
	if not wok or not wic then s+=2 end

	local tk,tv=o.pc(o.te,o.game)
	if not tk or tv~="DataModel" then s+=3 end

	if o.t(o.ncc)=="function" then
		local nc,nf=o.pc(o.ncc,function() end)
		local wok2,wic2=o.pc(o.ic,nf)
		if not nc or not wok2 or not wic2 then s+=2 end
	end

	return s
end

local dtc=false

for i=1,6 do
	local ok,result=o.pc(x)
	if not ok or result>=12 then
		dtc=true
		break
	end
	if o.t(o.w)=="function" then
		o.pc(o.w,0.03)
	end
end

o.p(dtc and "dtc" or "ud")
