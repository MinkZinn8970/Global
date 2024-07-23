--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
			return Res - (Res % 1);
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local a, b = Byte(ByteString, DIP, DIP + 2);
		DIP = DIP + 2;
		return (b * 256) + a;
	end
	local function gBits32()
		local FlatIdent_95CAC = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_95CAC == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
			if (FlatIdent_95CAC == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_95CAC = 1;
			end
		end
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_8D327 = 0;
				while true do
					if (FlatIdent_8D327 == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local FlatIdent_24A02 = 0;
		local Str;
		local FStr;
		while true do
			if (FlatIdent_24A02 == 3) then
				return Concat(FStr);
			end
			if (FlatIdent_24A02 == 0) then
				Str = nil;
				if not Len then
					local FlatIdent_63487 = 0;
					while true do
						if (FlatIdent_63487 == 0) then
							Len = gBits32();
							if (Len == 0) then
								return "";
							end
							break;
						end
					end
				end
				FlatIdent_24A02 = 1;
			end
			if (FlatIdent_24A02 == 2) then
				FStr = {};
				for Idx = 1, #Str do
					FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
				end
				FlatIdent_24A02 = 3;
			end
			if (FlatIdent_24A02 == 1) then
				Str = Sub(ByteString, DIP, (DIP + Len) - 1);
				DIP = DIP + Len;
				FlatIdent_24A02 = 2;
			end
		end
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_44839 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (0 == FlatIdent_44839) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_44839 = 1;
			end
			if (FlatIdent_44839 == 1) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local Type = gBits8();
					local Cons;
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
				end
				Chunk[3] = gBits8();
				FlatIdent_44839 = 2;
			end
			if (2 == FlatIdent_44839) then
				for Idx = 1, gBits32() do
					local Descriptor = gBits8();
					if (gBit(Descriptor, 1, 1) == 0) then
						local FlatIdent_1076E = 0;
						local Type;
						local Mask;
						local Inst;
						while true do
							if (FlatIdent_1076E == 3) then
								if (gBit(Mask, 3, 3) == 1) then
									Inst[4] = Consts[Inst[4]];
								end
								Instrs[Idx] = Inst;
								break;
							end
							if (1 == FlatIdent_1076E) then
								Inst = {gBits16(),gBits16(),nil,nil};
								if (Type == 0) then
									local FlatIdent_E652 = 0;
									while true do
										if (0 == FlatIdent_E652) then
											Inst[3] = gBits16();
											Inst[4] = gBits16();
											break;
										end
									end
								elseif (Type == 1) then
									Inst[3] = gBits32();
								elseif (Type == 2) then
									Inst[3] = gBits32() - (2 ^ 16);
								elseif (Type == 3) then
									Inst[3] = gBits32() - (2 ^ 16);
									Inst[4] = gBits16();
								end
								FlatIdent_1076E = 2;
							end
							if (FlatIdent_1076E == 0) then
								Type = gBit(Descriptor, 2, 3);
								Mask = gBit(Descriptor, 4, 6);
								FlatIdent_1076E = 1;
							end
							if (FlatIdent_1076E == 2) then
								if (gBit(Mask, 1, 1) == 1) then
									Inst[2] = Consts[Inst[2]];
								end
								if (gBit(Mask, 2, 2) == 1) then
									Inst[3] = Consts[Inst[3]];
								end
								FlatIdent_1076E = 3;
							end
						end
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_27957 = 0;
				while true do
					if (FlatIdent_27957 == 1) then
						if (Enum <= 38) then
							if (Enum <= 18) then
								if (Enum <= 8) then
									if (Enum <= 3) then
										if (Enum <= 1) then
											if (Enum == 0) then
												local Edx;
												local Results, Limit;
												local B;
												local A;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
											else
												local A;
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
											end
										elseif (Enum > 2) then
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
										else
											Stk[Inst[2]]();
										end
									elseif (Enum <= 5) then
										if (Enum == 4) then
											local A;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										else
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
										end
									elseif (Enum <= 6) then
										local FlatIdent_8F59B = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_8F59B == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8F59B = 5;
											end
											if (FlatIdent_8F59B == 2) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_8F59B = 3;
											end
											if (FlatIdent_8F59B == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_29B3D = 0;
													while true do
														if (FlatIdent_29B3D == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_8F59B = 4;
											end
											if (FlatIdent_8F59B == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8F59B = 1;
											end
											if (FlatIdent_8F59B == 5) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_8F59B == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_8F59B = 2;
											end
										end
									elseif (Enum == 7) then
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_3EEE1 = 0;
											while true do
												if (FlatIdent_3EEE1 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									end
								elseif (Enum <= 13) then
									if (Enum <= 10) then
										if (Enum > 9) then
											local FlatIdent_39764 = 0;
											local A;
											while true do
												if (FlatIdent_39764 == 0) then
													A = Inst[2];
													Stk[A] = Stk[A]();
													break;
												end
											end
										elseif (Stk[Inst[2]] == Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 11) then
										Stk[Inst[2]] = Inst[3];
									elseif (Enum == 12) then
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_494DF = 0;
											while true do
												if (FlatIdent_494DF == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										local FlatIdent_27404 = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_27404 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_27404 = 6;
											end
											if (FlatIdent_27404 == 6) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (FlatIdent_27404 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_27404 = 4;
											end
											if (FlatIdent_27404 == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_27404 = 1;
											end
											if (FlatIdent_27404 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_27404 = 2;
											end
											if (FlatIdent_27404 == 4) then
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_27404 = 5;
											end
											if (FlatIdent_27404 == 2) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_27404 = 3;
											end
										end
									end
								elseif (Enum <= 15) then
									if (Enum > 14) then
										local A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
									else
										local FlatIdent_8A742 = 0;
										local Edx;
										local Results;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_8A742 == 5) then
												Stk[Inst[2]]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (2 == FlatIdent_8A742) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_8A742 = 3;
											end
											if (FlatIdent_8A742 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8A742 = 5;
											end
											if (FlatIdent_8A742 == 0) then
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_8A742 = 1;
											end
											if (FlatIdent_8A742 == 3) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													local FlatIdent_8BC55 = 0;
													while true do
														if (FlatIdent_8BC55 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												FlatIdent_8A742 = 4;
											end
											if (FlatIdent_8A742 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_8A742 = 2;
											end
										end
									end
								elseif (Enum <= 16) then
									local A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
								elseif (Enum > 17) then
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_19F98 = 0;
										while true do
											if (FlatIdent_19F98 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								else
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum <= 28) then
								if (Enum <= 23) then
									if (Enum <= 20) then
										if (Enum == 19) then
											local FlatIdent_75224 = 0;
											local Edx;
											local Results;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_75224 == 6) then
													for Idx = A, Top do
														local FlatIdent_20FE3 = 0;
														while true do
															if (FlatIdent_20FE3 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													FlatIdent_75224 = 7;
												end
												if (FlatIdent_75224 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_75224 = 8;
												end
												if (FlatIdent_75224 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_75224 = 6;
												end
												if (FlatIdent_75224 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_75224 = 3;
												end
												if (FlatIdent_75224 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_75224 = 4;
												end
												if (FlatIdent_75224 == 4) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_75224 = 5;
												end
												if (FlatIdent_75224 == 8) then
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_75224 == 0) then
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_75224 = 1;
												end
												if (FlatIdent_75224 == 1) then
													Stk[A] = Stk[A]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													FlatIdent_75224 = 2;
												end
											end
										else
											local A;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										end
									elseif (Enum <= 21) then
										Stk[Inst[2]][Inst[3]] = Inst[4];
									elseif (Enum == 22) then
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									else
										local A;
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
									end
								elseif (Enum <= 25) then
									if (Enum > 24) then
										do
											return;
										end
									else
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
									end
								elseif (Enum <= 26) then
									local FlatIdent_578E3 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_578E3 == 3) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_578E3 = 4;
										end
										if (0 == FlatIdent_578E3) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_578E3 = 1;
										end
										if (FlatIdent_578E3 == 8) then
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_578E3 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											FlatIdent_578E3 = 8;
										end
										if (6 == FlatIdent_578E3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											FlatIdent_578E3 = 7;
										end
										if (FlatIdent_578E3 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_578E3 = 3;
										end
										if (4 == FlatIdent_578E3) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_578E3 = 5;
										end
										if (FlatIdent_578E3 == 5) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_2DA99 = 0;
												while true do
													if (FlatIdent_2DA99 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											FlatIdent_578E3 = 6;
										end
										if (FlatIdent_578E3 == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_578E3 = 2;
										end
									end
								elseif (Enum == 27) then
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								else
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 33) then
								if (Enum <= 30) then
									if (Enum > 29) then
										if (Inst[2] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 31) then
									VIP = Inst[3];
								elseif (Enum == 32) then
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								else
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
								end
							elseif (Enum <= 35) then
								if (Enum == 34) then
									local A = Inst[2];
									local T = Stk[A];
									for Idx = A + 1, Inst[3] do
										Insert(T, Stk[Idx]);
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								end
							elseif (Enum <= 36) then
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								do
									return;
								end
							elseif (Enum > 37) then
								local FlatIdent_31ECC = 0;
								local A;
								while true do
									if (FlatIdent_31ECC == 0) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
								end
							else
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							end
						elseif (Enum <= 58) then
							if (Enum <= 48) then
								if (Enum <= 43) then
									if (Enum <= 40) then
										if (Enum > 39) then
											local FlatIdent_2A644 = 0;
											local Edx;
											local Results;
											local Limit;
											local B;
											local A;
											while true do
												if (3 == FlatIdent_2A644) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
													Top = (Limit + A) - 1;
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													FlatIdent_2A644 = 4;
												end
												if (FlatIdent_2A644 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_2A644 = 2;
												end
												if (FlatIdent_2A644 == 0) then
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_2A644 = 1;
												end
												if (5 == FlatIdent_2A644) then
													Stk[Inst[2]]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (2 == FlatIdent_2A644) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_2A644 = 3;
												end
												if (FlatIdent_2A644 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_2A644 = 5;
												end
											end
										else
											local A = Inst[2];
											local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											local Edx = 0;
											for Idx = A, Top do
												local FlatIdent_2593F = 0;
												while true do
													if (FlatIdent_2593F == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
										end
									elseif (Enum <= 41) then
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									elseif (Enum == 42) then
										local FlatIdent_3B08E = 0;
										local A;
										while true do
											if (FlatIdent_3B08E == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
											if (FlatIdent_3B08E == 0) then
												A = nil;
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B08E = 1;
											end
											if (FlatIdent_3B08E == 1) then
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3B08E = 2;
											end
											if (3 == FlatIdent_3B08E) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_3B08E = 4;
											end
											if (FlatIdent_3B08E == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_3B08E = 3;
											end
										end
									else
										local B;
										local T;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
									end
								elseif (Enum <= 45) then
									if (Enum == 44) then
										local A = Inst[2];
										local T = Stk[A];
										local B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
									else
										local A = Inst[2];
										Stk[A](Stk[A + 1]);
									end
								elseif (Enum <= 46) then
									local FlatIdent_512FF = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_512FF == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											FlatIdent_512FF = 7;
										end
										if (1 == FlatIdent_512FF) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_512FF = 2;
										end
										if (FlatIdent_512FF == 3) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_512FF = 4;
										end
										if (FlatIdent_512FF == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_512FF = 5;
										end
										if (FlatIdent_512FF == 5) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_512FF = 6;
										end
										if (FlatIdent_512FF == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_512FF = 3;
										end
										if (FlatIdent_512FF == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_512FF = 1;
										end
										if (FlatIdent_512FF == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											FlatIdent_512FF = 8;
										end
										if (8 == FlatIdent_512FF) then
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
									end
								elseif (Enum > 47) then
									local A;
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum <= 53) then
								if (Enum <= 50) then
									if (Enum > 49) then
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										do
											return;
										end
									else
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									end
								elseif (Enum <= 51) then
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								elseif (Enum == 52) then
									local B;
									local T;
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								else
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 55) then
								if (Enum > 54) then
									local FlatIdent_8EA6E = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_8EA6E == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8EA6E = 2;
										end
										if (4 == FlatIdent_8EA6E) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											FlatIdent_8EA6E = 5;
										end
										if (5 == FlatIdent_8EA6E) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8EA6E = 6;
										end
										if (FlatIdent_8EA6E == 2) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_8EA6E = 3;
										end
										if (FlatIdent_8EA6E == 6) then
											Stk[Inst[2]]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_8EA6E == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8EA6E = 4;
										end
										if (FlatIdent_8EA6E == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_8EA6E = 1;
										end
									end
								else
									local FlatIdent_51C44 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_51C44 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]]();
											VIP = VIP + 1;
											FlatIdent_51C44 = 8;
										end
										if (FlatIdent_51C44 == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_51C44 = 2;
										end
										if (8 == FlatIdent_51C44) then
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
										if (FlatIdent_51C44 == 3) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_51C44 = 4;
										end
										if (FlatIdent_51C44 == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_51C44 = 5;
										end
										if (FlatIdent_51C44 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_51C44 = 3;
										end
										if (FlatIdent_51C44 == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_51C44 = 1;
										end
										if (FlatIdent_51C44 == 5) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_51C44 = 6;
										end
										if (FlatIdent_51C44 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											FlatIdent_51C44 = 7;
										end
									end
								end
							elseif (Enum <= 56) then
								local FlatIdent_508D4 = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_508D4 == 4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_508D4 = 5;
									end
									if (FlatIdent_508D4 == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										FlatIdent_508D4 = 1;
									end
									if (5 == FlatIdent_508D4) then
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_6F99F = 0;
											while true do
												if (FlatIdent_6F99F == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										FlatIdent_508D4 = 6;
									end
									if (FlatIdent_508D4 == 3) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_508D4 = 4;
									end
									if (FlatIdent_508D4 == 8) then
										Inst = Instr[VIP];
										do
											return;
										end
										break;
									end
									if (FlatIdent_508D4 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										FlatIdent_508D4 = 7;
									end
									if (FlatIdent_508D4 == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_508D4 = 3;
									end
									if (FlatIdent_508D4 == 1) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_508D4 = 2;
									end
									if (FlatIdent_508D4 == 7) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										FlatIdent_508D4 = 8;
									end
								end
							elseif (Enum == 57) then
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
							end
						elseif (Enum <= 68) then
							if (Enum <= 63) then
								if (Enum <= 60) then
									if (Enum == 59) then
										local FlatIdent_15034 = 0;
										local A;
										while true do
											if (1 == FlatIdent_15034) then
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_15034 = 2;
											end
											if (FlatIdent_15034 == 6) then
												Stk[Inst[2]] = {};
												break;
											end
											if (0 == FlatIdent_15034) then
												A = nil;
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_15034 = 1;
											end
											if (FlatIdent_15034 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_15034 = 3;
											end
											if (3 == FlatIdent_15034) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												FlatIdent_15034 = 4;
											end
											if (4 == FlatIdent_15034) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_15034 = 5;
											end
											if (FlatIdent_15034 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15034 = 6;
											end
										end
									else
										Stk[Inst[2]] = {};
									end
								elseif (Enum <= 61) then
									local B;
									local T;
									local A;
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									T = Stk[A];
									B = Inst[3];
									for Idx = 1, B do
										T[Idx] = Stk[A + Idx];
									end
								elseif (Enum == 62) then
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										local FlatIdent_74B46 = 0;
										while true do
											if (FlatIdent_74B46 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								else
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								end
							elseif (Enum <= 65) then
								if (Enum == 64) then
									local FlatIdent_30B1F = 0;
									local A;
									while true do
										if (FlatIdent_30B1F == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (FlatIdent_30B1F == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_30B1F = 4;
										end
										if (FlatIdent_30B1F == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_30B1F = 3;
										end
										if (4 == FlatIdent_30B1F) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_30B1F = 5;
										end
										if (FlatIdent_30B1F == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_30B1F = 2;
										end
										if (FlatIdent_30B1F == 0) then
											A = nil;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_30B1F = 1;
										end
									end
								else
									local FlatIdent_4BE81 = 0;
									local A;
									while true do
										if (FlatIdent_4BE81 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_4BE81 = 4;
										end
										if (FlatIdent_4BE81 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											break;
										end
										if (6 == FlatIdent_4BE81) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_4BE81 = 7;
										end
										if (FlatIdent_4BE81 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											FlatIdent_4BE81 = 2;
										end
										if (5 == FlatIdent_4BE81) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_4BE81 = 6;
										end
										if (0 == FlatIdent_4BE81) then
											A = nil;
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_4BE81 = 1;
										end
										if (FlatIdent_4BE81 == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											FlatIdent_4BE81 = 3;
										end
										if (FlatIdent_4BE81 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_4BE81 = 5;
										end
									end
								end
							elseif (Enum <= 66) then
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_59521 = 0;
									while true do
										if (FlatIdent_59521 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								do
									return;
								end
							elseif (Enum > 67) then
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							else
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									local FlatIdent_97B67 = 0;
									while true do
										if (FlatIdent_97B67 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]]();
								VIP = VIP + 1;
								Inst = Instr[VIP];
								do
									return;
								end
							end
						elseif (Enum <= 73) then
							if (Enum <= 70) then
								if (Enum > 69) then
									local A;
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = {};
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
								else
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 71) then
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							elseif (Enum > 72) then
								Stk[Inst[2]] = Stk[Inst[3]];
							else
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
							end
						elseif (Enum <= 75) then
							if (Enum > 74) then
								local FlatIdent_4D69A = 0;
								local Edx;
								local Results;
								local Limit;
								local B;
								local A;
								while true do
									if (FlatIdent_4D69A == 1) then
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										FlatIdent_4D69A = 2;
									end
									if (FlatIdent_4D69A == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										FlatIdent_4D69A = 7;
									end
									if (7 == FlatIdent_4D69A) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]]();
										VIP = VIP + 1;
										FlatIdent_4D69A = 8;
									end
									if (FlatIdent_4D69A == 0) then
										Edx = nil;
										Results, Limit = nil;
										B = nil;
										A = nil;
										FlatIdent_4D69A = 1;
									end
									if (FlatIdent_4D69A == 8) then
										Inst = Instr[VIP];
										do
											return;
										end
										break;
									end
									if (FlatIdent_4D69A == 3) then
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_4D69A = 4;
									end
									if (5 == FlatIdent_4D69A) then
										Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										FlatIdent_4D69A = 6;
									end
									if (FlatIdent_4D69A == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										FlatIdent_4D69A = 3;
									end
									if (FlatIdent_4D69A == 4) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_4D69A = 5;
									end
								end
							else
								local A;
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
							end
						elseif (Enum <= 76) then
							Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
						elseif (Enum == 77) then
							local A;
							Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							A = Inst[2];
							Stk[A](Unpack(Stk, A + 1, Inst[3]));
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Env[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = Stk[Inst[3]];
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]] = {};
							VIP = VIP + 1;
							Inst = Instr[VIP];
							Stk[Inst[2]][Inst[3]] = Inst[4];
						else
							local FlatIdent_98E39 = 0;
							local A;
							local B;
							while true do
								if (0 == FlatIdent_98E39) then
									A = Inst[2];
									B = Stk[Inst[3]];
									FlatIdent_98E39 = 1;
								end
								if (FlatIdent_98E39 == 1) then
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									break;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
					if (0 == FlatIdent_27957) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_27957 = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!613O00028O00027O004003093O00412O6442752O746F6E03043O004E616D6503163O00536F6E696E686120487562202854686520426573742903083O0043612O6C6261636B03073O004D616B65546162030B3O00426C6F7820467275697473030B3O00536F6E696E686120487562030C3O00476F6D752048756220322E30030B3O005961676F20536372697074026O000840026O00204003113O0045726120446F73204772696D6F6972657303083O00546F72612048756203073O0045726120487562026O00144003073O004D424D2048554203073O00572D417A757265030B3O0053702O656420487562205803083O005265647A20487562030A3O0046616946616F20487562026O001840030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F4C69627261727956322F6D61696E2F7265647A4C6962030A3O004D616B6557696E646F772O033O0048756203053O005469746C65030C3O004B696E67205363726970747303093O00416E696D6174696F6E030D3O006279203A204D696E6B446576372O033O004B657903093O004B657953797374656D0100030A3O004B65792053797374656D030B3O004465736372697074696F6E034O0003073O004B65794C696E6B03043O004B65797303043O003132333403063O004E6F74696669030D3O004E6F74696669636174696F6E732O01030A3O00436F2O726563744B657903153O0052752O6E696E6720746865205363726970743O2E030C3O00496E636F2O726563746B657903143O00546865206B657920697320696E636F2O72656374030B3O00436F70794B65794C696E6B03133O00436F7069656420746F20436C6970626F617264030A3O004D616B654E6F7469666903103O004B696E6720536372697074732048756203043O005465787403253O0054686973205363726970742057617320446576656C6F706564204279204D696E6B5A692O6E03043O0054696D65030E3O004D696E696D697A6542752O746F6E03053O00496D61676503183O00726278612O73657469643A2O2F31372O38342O3133312O3403043O0053697A65026O00444003053O00436F6C6F7203063O00436F6C6F723303073O0066726F6D524742026O00244003063O00436F726E657203063O005374726F6B65030B3O005374726F6B65436F6C6F72025O00E06F4003043O004D61696E026O00F03F030A3O0042616E616E6120487562030A3O0053756B756E612048756203083O005865726F20487562026O00104003083O00536172612048756203093O00412O6E696520487562030B3O005768696E7465722048756203093O004E6F766F2032303234030A3O00426C6164652042612O6C03233O0053752O67657374696F6E7320466F7220446973636F7264204B696E6720506C65617365026O001C40030C3O00412O64506172616772617068030D3O0056657273C3A36F20312E382E3703153O004C696E6B20466F7220446973636F7264204B696E6703153O004C696E6B20466F7220596F7554756265204B696E6703153O004C696E6B20466F7220446973636F7264204D696E6B030A3O0046652053637269707473030B3O004B696E67204C656761637903093O0048797065722048756203073O004F6D6720487562030B3O0044656D6F6E20506965636503093O004E696E6A612048756203073O004E656F2048756203093O004D617269732048756203083O00486F486F20487562030C3O004D656C696F646173204875620081012O00120B3O00014O0048000100023O0026093O00260001000200041F3O0026000100122F000300034O0049000400014O003C00053O000200301500050004000500024C00065O00103B0005000600064O00030005000100122O000300076O00043O000100302O0004000400084O0003000200024O000100033O00122O000300036O000400016O00053O000200301500050004000900024C000600013O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004000A00024C000600023O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004000B00024C000600033O0010250005000600062O000F00030005000100120B3O000C3O0026093O003C0001000D00041F3O003C000100122F000300074O004100043O000100302O00040004000E4O0003000200024O000100033O00122O000300036O000400016O00053O000200302O00050004000F00024C000600043O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004001000024C000600053O0010250005000600062O000F00030005000100041F3O00802O010026093O00620001001100041F3O0062000100122F000300034O0049000400014O003C00053O000200301500050004001200024C000600063O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004001300024C000600073O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004001400024C000600083O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004001500024C000600093O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004001600024C0006000A3O0010250005000600062O000F00030005000100120B3O00173O0026093O00A70001000100041F3O00A7000100122F000300183O001244000400193O00202O00040004001A00122O0006001B6O000400066O00033O00024O00030001000100122O0003001C6O00043O00024O00053O000200302O0005001E001F0030150005002000210010340004001D00054O00053O000600302O00050023002400302O0005001E002500302O00050026002700302O0005002800274O000600013O00122O0007002A6O0006000100010010250005002900062O003000063O000400302O0006002C002D00302O0006002E002F00302O00060030003100302O00060032003300102O0005002B000600102O0004002200054O00030002000100122O000300346O00043O00030030150004001E003500303D00040036003700302O0004003800114O00030002000100122O000300396O00043O000600302O0004003A003B4O000500023O00122O0006003D3O00122O0007003D6O0005000200010010250004003C00050012180005003F3O00202O00050005004000122O000600413O00122O000700413O00122O000800416O00050008000200102O0004003E000500302O00040042002D00302O00040043002400122O0005003F3O002023000500050040001217000600453O00122O000700013O00122O000800016O00050008000200102O0004004400054O00030002000100122O000300076O00043O000100302O0004000400464O0003000200022O0049000100033O00120B3O00473O0026093O00D80001000C00041F3O00D8000100120B000300013O000E1E004700BB0001000300041F3O00BB000100122F000400034O0049000500014O003C00063O000200301500060004004800024C0007000B3O0010140006000600074O00040006000100122O000400036O000500016O00063O000200302O00060004004900024C0007000C3O0010250006000600072O000F00040006000100120B000300023O002609000300C60001000200041F3O00C6000100122F000400034O0049000500014O003C00063O000200301500060004004A00024C0007000D3O0010250006000600072O000F00040006000100120B3O004B3O00041F3O00D80001002609000300AA0001000100041F3O00AA000100122F000400034O0049000500014O003C00063O000200301500060004004C00024C0007000E3O0010140006000600074O00040006000100122O000400036O000500016O00063O000200302O00060004004D00024C0007000F3O0010250006000600072O000F00040006000100120B000300473O00041F3O00AA00010026093O00FC0001001700041F3O00FC000100122F000300034O0049000400014O003C00053O000200301500050004004E00024C000600103O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004004F00024C000600113O00103B0005000600064O00030005000100122O000300076O00043O000100302O0004000400504O0003000200024O000100033O00122O000300036O000400016O00053O000200301500050004000900024C000600123O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004005100024C000600133O0010250005000600062O000F00030005000100120B3O00523O0026093O00212O01004700041F3O00212O0100122F000300534O002B000400016O000500023O00122O000600543O00122O000700276O0005000200012O00260003000500022O0008000200033O00122O000300036O000400016O00053O000200302O00050004005500024C000600143O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004005600024C000600153O0010140005000600064O00030005000100122O000300036O000400016O00053O000200302O00050004005700024C000600163O00101D0005000600064O00030005000100122O000300076O00043O000100302O0004000400584O0003000200024O000100033O00124O00023O0026093O004E2O01005200041F3O004E2O0100120B000300013O002609000300332O01000100041F3O00332O0100122F000400074O004100053O000100302O0005000400594O0004000200024O000100043O00122O000400036O000500016O00063O000200302O00060004005A00024C000700173O0010250006000600072O000F00040006000100120B000300473O0026090003003E2O01000200041F3O003E2O0100122F000400034O0049000500014O003C00063O000200301500060004005B00024C000700183O0010250006000600072O000F00040006000100120B3O000D3O00041F3O004E2O01002609000300242O01004700041F3O00242O0100122F000400034O0049000500014O003C00063O000200301500060004005100024C000700193O00101D0006000600074O00040006000100122O000400076O00053O000100302O00050004005C4O0004000200024O000100043O00122O000300023O00041F3O00242O010026093O00020001004B00041F3O0002000100120B000300013O002609000300622O01000100041F3O00622O0100122F000400034O0049000500014O003C00063O000200301500060004005D00024C0007001A3O0010140006000600074O00040006000100122O000400036O000500016O00063O000200302O00060004005E00024C0007001B3O0010250006000600072O000F00040006000100120B000300473O002609000300732O01004700041F3O00732O0100122F000400034O0049000500014O003C00063O000200301500060004005F00024C0007001C3O0010140006000600074O00040006000100122O000400036O000500016O00063O000200302O00060004006000024C0007001D3O0010250006000600072O000F00040006000100120B000300023O002609000300512O01000200041F3O00512O0100122F000400034O0049000500014O003C00063O000200301500060004006100024C0007001E3O0010250006000600072O000F00040006000100120B3O00113O00041F3O0002000100041F3O00512O0100041F3O000200012O00193O00013O001F3O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4D696E6B446576372F536F6E696E68614875622F6D61696E2F4C6F616465722E4C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4D696E6B446576372F536F6E696E68614875622F6D61696E2F4C6F616465722E4C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403393O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F706F6B656C6F6B2F476F6D752D322E302F6D61696E2F3200083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403393O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F706F6B656C6F6B2F7961676F582F6D61696E2F6D61696E00083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403423O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F546F72615363726970742F5363726970742F6D61696E2F4772696D6F6972657300083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403423O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4C4F4C6B696E673132333435362F4772696D6F697265732F6D61696E2F45726100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403443O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D314D2D506C7165723831392F616E792F6D61696E2F6D626D786875622F3031333500083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00083O00028O0003073O0067657467656E7603043O005465616D03073O0050697261746573030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034D3O00682O7470733A2O2F6170692E6C7561726D6F722E6E65742F66696C65732F76332F6C6F61646572732F33623231363963663533626336313034646162653865313935363265352O63322E6C756100103O00120B3O00013O0026093O00010001000100041F3O0001000100122F000100024O001300010001000200302O00010003000400122O000100053O00122O000200063O00202O00020002000700122O000400086O000200046O00013O00024O00010001000100044O000F000100041F3O000100012O00193O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403493O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F61686D61647367616D6572322F53702O65642D4875622D582F6D61696E2F53702O65644875625800083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403423O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5245447A4855422F426C6F784672756974732F6D61696E2F7265647A4O3900083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F504E677579656E30312O392F5363726970742F6D61696E2F4661692D46616F2E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403483O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E676869612O316E2F42616E616E612D4875622F6D61696E2F62616E616E616875622E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403443O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5363726970742D426C6F782F5363726970742F6D61696E2F53756B756E612D48756200083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403413O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F76657275646F75732F5865726F2D4875622F6D61696E2F6D61696E2E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403443O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5361726153656E7061692F626C6F786672756973742F6D61696E2F5361726168756200083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403473O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F412O6E6965637574692F46722O652D5363722F6D61696E2F412O6E69652D4875622E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5961747375722O612F597572692F6D61696E2F57696E7465726875625F56322E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403213O00682O7470733A2O2F706173746562696E2E636F6D2F7261772F41596D717A46416B00083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4D696E6B446576372F536F6E696E68614875622F6D61696E2F4C6F616465722E4C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00019O003O00014O00193O00017O00023O00030C3O00736574636C6970626F61726403243O00682O7470733A2O2F646973636F72642E2O672F696E766974652F3244617935364D34587300043O00122F3O00013O00120B000100024O002D3O000200012O00193O00017O00023O00030C3O00736574636C6970626F61726403383O00682O7470733A2O2F796F75747562652E636F6D2F406B696E672E6F662E736372697074733F73693D6D73347A5379785F5672586C4D50786100043O00122F3O00013O00120B000100024O002D3O000200012O00193O00017O00023O00030C3O00736574636C6970626F61726403253O00682O7470733A2O2F646973636F72642E636F6D2F696E766974652F57484D3676646538425000043O00122F3O00013O00120B000100024O002D3O000200012O00193O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403423O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F442O6F6B44656B442O452F48797065722F6D61696E2F7363726970742E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4F6D67736869742F536372697074732F6D61696E2F4D61696E4C6F616465722E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00019O003O00014O00193O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403453O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F5865726F323430392F4E696E6A614875622F6D61696E2F6E696E6A616875622E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F4E494748544855424F4E544F502F4D61696E2F6D61696E2F4C6F616465725363726970742E6C756100083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403493O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F6D61726973646570747261692F5363726970742D46722O652F6D61696E2F4D617269732D48756200083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403403O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F616373753132332F484F484F5F482F6D61696E2F4C6F6164696E675F554900083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00043O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574033C3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F706F6B656C6F6B2F73756E612F6D61696E2F6D656C696F64617300083O0012453O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O000100016O00017O00", GetFEnv(), ...);