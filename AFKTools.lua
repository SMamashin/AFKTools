script_name('AFK Tools (upd)') -- iphone
script_author("bakhusse x mamashin.")
script_version('2.5.1') --fix
script_properties('work-in-pause')
local dlstatus = require("moonloader").download_status
local imgui = require('imgui')
local encoding = require("encoding")
local sampev = require("samp.events")
local memory = require("memory")
local effil = require("effil")
local inicfg = require("inicfg")
local ffi = require("ffi")
local requests = require("requests")
encoding.default = 'CP1251'
u8 = encoding.UTF8

if not doesDirectoryExist('moonloader/config') then
	createDirectory('moonloader/config')
end

local path = getWorkingDirectory() .. "\\config"

local function closeDialog()
	sampSetDialogClientside(true)
	sampCloseCurrentDialogWithButton(0)
	sampSetDialogClientside(false)
end
local fix = false
local use = false
local delplayeractive = imgui.ImBool(false)
local npc, infnpc = {}, {}
local mainIni = inicfg.load({
	autologin = {
		state = false
	},
	arec ={
		state = false,
		statebanned = false,
		wait = 50
	},
	roulette = {
		standart = false,
		donate = false,
		platina = false,
		mask = false,
		tainik = false,
		wait = 1000
	},
	vknotf = {
		token = '',
		user_id = '',
		group_id = '',
		state = false,
		isinitgame = false,
		ishungry = false,
		iscloseconnect = false,
		isadm = false,
		iscode = false,
		isdemorgan = false,
		islowhp = false,
		ispayday = false,
		iscrashscript = false,
		issellitem = false,
		issmscall = false,
		bank = false,
		record = false,
		ismeat = false,
		dienable = false
	},
	autologinfix = {
		state = false,
		nick = '',
		pass = ''
	},
	find = {
		vkfind = false,
		vkfindtext = false,
		vkfindtext2 = false,
		vkfindtext3 = false,
		vkfindtext4 = false,
		vkfindtext5 = false,
		vkfindtext6 = false,
		vkfindtext7 = false,
		vkfindtext8 = false,
		vkfindtext9 = false,
		vkfindtext10 = false,
		inputfindvk = '',
		inputfindvk2 = '',
		inputfindvk3 = '',
		inputfindvk4 = '',
		inputfindvk5 = '',
		inputfindvk6 = '',
		inputfindvk7 = '',
		inputfindvk8 = '',
		inputfindvk9 = '',
		inputfindvk10 = '',
	},
	piar = {
		piar1 = '',
		piar2 = '',
		piar3 = '',
		piarwait = 50,
		piarwait2 = 50,
		piarwait3 = 50,
		auto_piar = false,
		auto_piar_kd = 300,
		last_time = os.time(),
	},
	eat = {
		checkmethod = 0,
		eat2met = 30,
		cycwait = 30,
		setmetod = 0,
        eatmetod = 0,
        healstate = false,
        hplvl = 30,
        hpmetod = 0,
        arztextdrawid = 648,
        arztextdrawidheal = 646,
        drugsquen = 1
	},
	config = {
		banscreen = false,
		autoupdate = true,
		antiafk = false,
		autoad = false,
		autoo = false,
		atext = '',
		aphone = 0,
		autoadbiz = false,
		fastconnect = false
	},
	buttons = {
		binfo = true
	}
},'afktools.ini')

ffi.cdef[[
    typedef unsigned long DWORD;

    struct d3ddeviceVTBL {
        void *QueryInterface;
        void *AddRef;
        void *Release;
        void *TestCooperativeLevel;
        void *GetAvailableTextureMem;
        void *EvictManagedResources;
        void *GetDirect3D;
        void *GetDeviceCaps;
        void *GetDisplayMode;
        void *GetCreationParameters;
        void *SetCursorProperties;
        void *SetCursorPosition;
        void *ShowCursor;
        void *CreateAdditionalSwapChain;
        void *GetSwapChain;
        void *GetNumberOfSwapChains;
        void *Reset;
        void *Present;
        void *GetBackBuffer;
        void *GetRasterStatus;
        void *SetDialogBoxMode;
        void *SetGammaRamp;
        void *GetGammaRamp;
        void *CreateTexture;
        void *CreateVolumeTexture;
        void *CreateCubeTexture;
        void *CreateVertexBuffer;
        void *CreateIndexBuffer;
        void *CreateRenderTarget;
        void *CreateDepthStencilSurface;
        void *UpdateSurface;
        void *UpdateTexture;
        void *GetRenderTargetData;
        void *GetFrontBufferData;
        void *StretchRect;
        void *ColorFill;
        void *CreateOffscreenPlainSurface;
        void *SetRenderTarget;
        void *GetRenderTarget;
        void *SetDepthStencilSurface;
        void *GetDepthStencilSurface;
        void *BeginScene;
        void *EndScene;
        void *Clear;
        void *SetTransform;
        void *GetTransform;
        void *MultiplyTransform;
        void *SetViewport;
        void *GetViewport;
        void *SetMaterial;
        void *GetMaterial;
        void *SetLight;
        void *GetLight;
        void *LightEnable;
        void *GetLightEnable;
        void *SetClipPlane;
        void *GetClipPlane;
        void *SetRenderState;
        void *GetRenderState;
        void *CreateStateBlock;
        void *BeginStateBlock;
        void *EndStateBlock;
        void *SetClipStatus;
        void *GetClipStatus;
        void *GetTexture;
        void *SetTexture;
        void *GetTextureStageState;
        void *SetTextureStageState;
        void *GetSamplerState;
        void *SetSamplerState;
        void *ValidateDevice;
        void *SetPaletteEntries;
        void *GetPaletteEntries;
        void *SetCurrentTexturePalette;
        void *GetCurrentTexturePalette;
        void *SetScissorRect;
        void *GetScissorRect;
        void *SetSoftwareVertexProcessing;
        void *GetSoftwareVertexProcessing;
        void *SetNPatchMode;
        void *GetNPatchMode;
        void *DrawPrimitive;
        void* DrawIndexedPrimitive;
        void *DrawPrimitiveUP;
        void *DrawIndexedPrimitiveUP;
        void *ProcessVertices;
        void *CreateVertexDeclaration;
        void *SetVertexDeclaration;
        void *GetVertexDeclaration;
        void *SetFVF;
        void *GetFVF;
        void *CreateVertexShader;
        void *SetVertexShader;
        void *GetVertexShader;
        void *SetVertexShaderConstantF;
        void *GetVertexShaderConstantF;
        void *SetVertexShaderConstantI;
        void *GetVertexShaderConstantI;
        void *SetVertexShaderConstantB;
        void *GetVertexShaderConstantB;
        void *SetStreamSource;
        void *GetStreamSource;
        void *SetStreamSourceFreq;
        void *GetStreamSourceFreq;
        void *SetIndices;
        void *GetIndices;
        void *CreatePixelShader;
        void *SetPixelShader;
        void *GetPixelShader;
        void *SetPixelShaderConstantF;
        void *GetPixelShaderConstantF;
        void *SetPixelShaderConstantI;
        void *GetPixelShaderConstantI;
        void *SetPixelShaderConstantB;
        void *GetPixelShaderConstantB;
        void *DrawRectPatch;
        void *DrawTriPatch;
        void *DeletePatch;
    };

    struct d3ddevice {
        struct d3ddeviceVTBL** vtbl;
    };
    
    struct RECT {
        long left;
        long top;
        long right;
        long bottom;
    };
    
    struct POINT {
        long x;
        long y;
    };
    
    int __stdcall GetSystemMetrics(
      int nIndex
    );
    
    int __stdcall GetClientRect(
        int   hWnd,
        struct RECT* lpRect
    );
    
    int __stdcall ClientToScreen(
        int    hWnd,
        struct POINT* lpPoint
    );
    
    int __stdcall D3DXSaveSurfaceToFileA(
        const char*          pDestFile,
        int DestFormat,
        void*       pSrcSurface,
        void*        pSrcPalette,
        struct RECT                 *pSrcRect
    );
	
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
	
	void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
	uint32_t __stdcall CoInitializeEx(void*, uint32_t);

	int __stdcall GetVolumeInformationA(
    const char* lpRootPathName,
    char* lpVolumeNameBuffer,
    uint32_t nVolumeNameSize,
    uint32_t* lpVolumeSerialNumber,
    uint32_t* lpMaximumComponentLength,
    uint32_t* lpFileSystemFlags,
    char* lpFileSystemNameBuffer,
    uint32_t nFileSystemNameSize
);
]]

if not doesFileExist('moonloader/config/afktools.ini') then
	inicfg.save(mainIni,'afktools.ini')
end

changelog = [[
	v1.0
		�����
	v1.1 
		������� ��������������
		������� ����� ������� ��� ����������� 
		������� ���������, ������ ��� ��������������
	v1.2
		���������� ����� ����� �������: !getplstats, !getplinfo, !send(� ��� �� ������) 
		����� ������� ��� �������� �����������: ��� ������ �� ���������
		������� ������ �� 3 ������(���� 2 ��� 3 ������ �� ����� �������� � ������)
	v1.25 - Hotfix
		�������� ���� ��� �������� ����������� � ��� ��� ���� �������
	v1.3
		������� �������� ����� ������� (����������� ������� ��� ������� ���� ��������)
		��� ���������: ������� ����������� �������� VK Notifications � �������� ������������ ������
	v1.4
		�������� ������������ ���� ���� ��������
	v1.5
		��������� ������� �������� �����������
		������ �������� �� ������
	v1.6
		����� �� BlastHack
		� ������ ������ ������� ��������� ���� ��������
		������, ���� ��� ���� ����� � �������� ����������� � ������, � ����������� ������� ��� ��� ����
		��������� � ����
	v1.6.1
		���� VK Notifications
	v1.7
		� VK Notifications ��������� ������ "�����" � ������� !getplhun
		��������� ����������� ��������� ��������������
		���������� ������ ����������� �� ��������� �� ��������������
	v1.8 
		������� ������ �������, ����� ������ � ���� ��������
		�������� ���� ���� �����
	v1.8-fix
		���� ����� ��� ����������
	v1.9
		����� ������
		�������� ��������
		��������� �������� �� /pm �� �������(������ + ���, 2 ����)
		���� AutoBanScreen - ������, ������� ��� ��������� ������� � ����
	v1.9.1
		���� ����� �� ����
	v1.9.1.1
		���� ���������� �������� ��� ������������
	v2.0.0
		��������� �����(����� ���) ��� ����������, ������������� ���� VK
		������ ������ �� ����� ��������
		� �������������� ��������� ������ "�������� �������"
		��������� ������� /afkrec(����� � ���������), /afksrec(������� ��������� � ����� �������)
]]
changelog2 = [[	v2.0.1
		���� ������������
	v2.0.2
		������� - �������� ����� �������� ����� ����� ��������(������� ������ � ����������) 
		���� ������ ��-�� ����� � ��.
		�������� Fastconnect
	v2.0.3
		����� �����
	v2.0.4
		���������� ��������������
		� VK Notifications ��������� ������ "SMS � ������"
	v2.0.5
		� VK Notifications ��������� ������ "�� �����/�������", � ����� "��� � �����/��"
		��������� ������� !sendcode !sendvk ��� �������� ����� ������������� �� �� � ����.
	v2.0.6
		�������� ������������, ������� ��� ������� ������ � �������� �������� �������� � ��.
		��������� ������ �������, ����� ����� ������������� �� �������� �� ��.
		� �� ��������� ������� !p (������� ������) � !h (�������� ������). �������� ����� ����� !send [�����].
	v2.0.7
		���� � ��������� ����������� /ad, �� ��� ����� �������� �������� /ad (��� ������� � ������������).
		�������� ���� � �� "The server didn't respond".
		�������������� �� ��.
	v2.0.8
		������� �������� ��� ������������� ������� !p, !h (������ ������ ��������� ��������� ���� �� ��������������)
		������ ������ �� ��������� ��� ������� ���� � �����/��.
		��������� ������������, � ����� ������ �������.
		������ ���� 2 ������ �������:
			- � ��� ������������ �������� (��� ��� ��� �� �����)
			- ��� ������������� �������, ���������� ������ (��� ��� ��� ����� ���� ������)
		��������� ������� !gauth ��� �������� ���� �� GAuthenticator
		���� �������� ���������� ����� ������, �� ������ �����������]]
changelog3 = [[
	v2.0.9
		������ �� ������������ ����� ������ ���� �����.
		� �� ��������� ������ "��������� 10 ����� � ����"
		��������� ������� ������������ ��������� � /vr ��-�� ��.
		������ ������ ������������ ��������������.
	v2.0.9.1
		��������� ��������.
		��������� ���� /ad.
	v2.0.9.2
		��������� ��������� ������������ � ����� �� ������ � ��.
		���������� ����.
	v2.1.0
		���������� ������ ��������� ������� /vr.
		������ ����� �������� �������� ���� �������� � ��.
		��������� �������������� � ��������� � ���� ����� !d [����� ��� �����] � !dc (��������� ������).
		������ ���������� ������� � ���� ����� ��� !send, �� ���������� ����� � ��� ����� ���� ��� �� �����.
		��������� ������ � ������� ���� ��� �������.
		��������� � �������� ����������.
		�������� ������������, ������� ���. �������.
	v2.2
		������ �������� �� ���� ����� �������� � ��.
		������� ��������� ������ ��� ���������� ���������/������ ��������:
			� ������������ �� bakhusse
			� AntiAFK by AIR
			� ���������� ��� ������ !screen
		�������� ������� ���� "��� ���������" � "��� ��������� !screen" � VK Notifications.
		�������� �������������� � ������ � ��������.
		��������� ������:
			� OK � Cancel ��� ���������� ����
			� ALT
			� ESC ��� �������� TextDraw
		������� ����������� �� ��������� ��� ����������� ����������� ��������.
		� ������ "���������" ���� ��������� ����� �������.
		��������� ����� � "��� ���������" � VK Notifications.
		������ ��� ���������� ������� "�������� ���� ��������" ��������� �� ������������ �� 2 ����.
		�������� ���������� ������� �� ������� � "����������"
]]
changelog4 = [[
	v2.3
		������ ������ ���������� ����� �������� �� �������� ����������.
		�������� ���� ���� �� ������ ALT �� ��.
		������� ������ ������������ /vr � ���� /vr �� ������ ���������� ������� �� Cosmo.
		��������� �������� ���������� ������ � ��.
		������� ������ �� ������ ��, �� ������������, Telegram-�����.
		��� �������� ���������� ���� ������ ����� � ��������� 
			(��� ��� �������� ��� ������ ������ � ����� ������).
		������ ����� �� ����� ��������� ���� � ���������(� �������� �� 30 ���.)
		�������� ������� ���� ������� /ad �� ���������.
		������� ������� "������ ����� � �������".
		������� ���. ����� ��� ������������� !screen.
	v2.4
		������ ������ �� �������� ��������� � /vr �� ����� ������������ � ��.
		��������� ������ �������/��������� ������ ��� �������� ������ � ��.
		��������� ������������, ����� �� ������� Y � �� ���� ������.
		��������� ������ �������� � ������� � ��.
		��������� ������ ��� ���������� ������� � �������� ��� ���.
	v2.5
		�������� ������� � ��� ��.
		� ������� ��������� ��������
	v2.5.1 HOTFIX
		� �������� ��������� �������� ��������� ��� ����� �����������.


]]
scriptinfo = [[
	AFK Tools - ������, ��� �������� �������� �� Arizona Role Play
	� ������ ������� �� ������ ����� �������� ������ � �������

	������� �������:
		/afktools - ������� ���� �������
		/afkreload - ������������� ������ 
		/afkunload - ��������� ������
		/afkrec - ��������� � ���������
		/afksrec - ���������� ���������(����������� ��� ���������) 
]]


howsetVK = [[
��� ����� Token?
1. �������� ������ VK ��� �����������
2. ������� � ���������� -> ��������� -> ������ � API -> ����� �������
3. ������� ������� ����
4. �������� 2 ������:
	��������� ���������� ������ � ���������� �����������
	��������� ���������� ������ � ���������� ����������
5. ������� "�������"
6. ���� ��������� ����������� ��������
7. ����� ����� � ��� �������� �����, ���������� ��� � �������� � ���� "�����"

��� ��������� ������� !getstats, !getinfo � ��.?

��������� �� ������� "Long Poll API", � ���������� "���������" �������� ���, �������� ������ 5.80(������ ������ 5.50)
��������� � ������� "���� �������", ��� ������ ������� �� �������� ���������. ������!
�� ������� "���������" ������ �������� ��������� ���������� � �� �������� ����� �� ��������� 
	��������� �� ���������� � ������� �������� ������(��� �� ������ ���-�� ����� � ��������� ������).
������ ���������� ��� �� ������������ ����������� ����� � ������: 
	���������� - ��������� - ��������� ����� - ����������� ����� - ��������
� ������� ����� ����� ��������� ID ������, ������� �� ������� ����.
p.s ���� ID ������ �� � ���� �����, �� ������ ��� ������ � ������� � �������
	��������: ������ �� ������: https://vk.com/im?sel=-194187813, ��� 194187813 ��� ID ������ 
p.s.s ���� � ��� �� ���� �� ����� ID ������, ��������� ��������� � ������� "��������������� � ��������"

��� ����� VK ID?
����� ������� ������
1. ������� � ������ vk.com/notify.arizona
2. ������� "��� ����� ID VK"
3. ��� ��� ���� ����� - ��� ��� ID VK
4. ���������� ��� ����� � ���� "VK ID" 

���������
������, �� ������ ��������� ����������� ����� ������ "���������"

���� � ��� ������ "Can't send messages for users without permission", 
�� �������� � ���� ������, � ��������� �����.
]]
howscreen = [[
������� !screen �������� ��������� �������:
� ���� ���� ������� - ���������� ���� �������
� ���� ���� �� ���� ����� - ����� ������ ����� ��������. 
� ����� ��������� �������� - ����� ������� ���� � ������� ����� 
  � ��������� �� ���� ����� (�� �������� ����� ������ � ����������
  �������� �������� ������� �����).
� ��� ������ ������� ����� ������� �����������
  ���������� (������� ����� � ���� VK Notifications)
� ����� �������� ������ ���������, ������� ������ ������������
  ���������� Alt + Enter, ����� Win + ������� �����.
]]
local _message = {}

function AFKMessage(text,del)
	del = del or 5
	_message[#_message+1] = {active = false, time = 0, showtime = del, text = text}
end
--ale op, load
local fastconnect = imgui.ImBool(mainIni.config.fastconnect)
local antiafk = imgui.ImBool(mainIni.config.antiafk)
local banscreen = imgui.ImBool(mainIni.config.banscreen)
local autoupdateState = imgui.ImBool(mainIni.config.autoupdate)
local autoad = imgui.ImBool(mainIni.config.autoad)
local autoo = imgui.ImBool(mainIni.config.autoo)
local atext = imgui.ImBuffer(''..mainIni.config.atext,300)
local aphone = imgui.ImInt(mainIni.config.aphone)
local autoadbiz = imgui.ImBool(mainIni.config.autoadbiz)
local binfo = imgui.ImBool(mainIni.buttons.binfo)
local autologin = {
	state = imgui.ImBool(mainIni.autologin.state)
}
local arec = {
	state = imgui.ImBool(mainIni.arec.state),
	statebanned = imgui.ImBool(mainIni.arec.statebanned),
	wait = imgui.ImInt(mainIni.arec.wait)
}
local roulette = {
	standart = imgui.ImBool(mainIni.roulette.standart),
	donate = imgui.ImBool(mainIni.roulette.donate),
	platina = imgui.ImBool(mainIni.roulette.platina),
	mask = imgui.ImBool(mainIni.roulette.mask),
	tainik = imgui.ImBool(mainIni.roulette.tainik),
	wait = imgui.ImInt(mainIni.roulette.wait)
}
local vknotf = {
	token = imgui.ImBuffer(''..mainIni.vknotf.token,300),
	user_id = imgui.ImBuffer(''..mainIni.vknotf.user_id,300),
	group_id = imgui.ImBuffer(''..mainIni.vknotf.group_id,300),
	state = imgui.ImBool(mainIni.vknotf.state),
	isinitgame = imgui.ImBool(mainIni.vknotf.isinitgame),
	ishungry = imgui.ImBool(mainIni.vknotf.ishungry),
	issmscall = imgui.ImBool(mainIni.vknotf.issmscall),
	bank = imgui.ImBool(mainIni.vknotf.bank),
	record = imgui.ImBool(mainIni.vknotf.record),
	ismeat = imgui.ImBool(mainIni.vknotf.ismeat),
	dienable = imgui.ImBool(mainIni.vknotf.dienable),
	iscloseconnect = imgui.ImBool(mainIni.vknotf.iscloseconnect),
	isadm = imgui.ImBool(mainIni.vknotf.isadm),
	iscode = imgui.ImBool(mainIni.vknotf.iscode),
	isdemorgan = imgui.ImBool(mainIni.vknotf.isdemorgan),
	islowhp = imgui.ImBool(mainIni.vknotf.islowhp),
	issendlowhp = false,
	ispayday = imgui.ImBool(mainIni.vknotf.ispayday),
	iscrashscript = imgui.ImBool(mainIni.vknotf.iscrashscript),
	ispaydaystate = false,
	ispaydayvalue = 0,
	ispaydaytext = '',
	issellitem = imgui.ImBool(mainIni.vknotf.issellitem)
}
local autologinfix = {
	state = imgui.ImBool(mainIni.autologinfix.state),
	nick = imgui.ImBuffer(''..mainIni.autologinfix.nick,50),
	pass = imgui.ImBuffer(''..mainIni.autologinfix.pass,50)
}
local piar = {
	piar1 = imgui.ImBuffer(''..mainIni.piar.piar1, 500),
	piar2 = imgui.ImBuffer(''..mainIni.piar.piar2, 500),
	piar3 = imgui.ImBuffer(''..mainIni.piar.piar3, 500),
	piarwait = imgui.ImInt(mainIni.piar.piarwait),
	piarwait2 = imgui.ImInt(mainIni.piar.piarwait2),
	piarwait3 = imgui.ImInt(mainIni.piar.piarwait3),
	auto_piar = imgui.ImBool(mainIni.piar.auto_piar),
	auto_piar_kd = imgui.ImInt(mainIni.piar.auto_piar_kd),
	last_time = mainIni.piar.last_time
}
local find = {
	vkfind = imgui.ImBool(mainIni.find.vkfind),
	vkfindtext = imgui.ImBool(mainIni.find.vkfindtext),
	vkfindtext2 = imgui.ImBool(mainIni.find.vkfindtext2),
	vkfindtext3 = imgui.ImBool(mainIni.find.vkfindtext3),
	vkfindtext4 = imgui.ImBool(mainIni.find.vkfindtext4),
	vkfindtext5 = imgui.ImBool(mainIni.find.vkfindtext5),
	vkfindtext6 = imgui.ImBool(mainIni.find.vkfindtext6),
	vkfindtext7 = imgui.ImBool(mainIni.find.vkfindtext7),
	vkfindtext8 = imgui.ImBool(mainIni.find.vkfindtext8),
	vkfindtext9 = imgui.ImBool(mainIni.find.vkfindtext9),
	vkfindtext10 = imgui.ImBool(mainIni.find.vkfindtext10),
	inputfindvk = imgui.ImBuffer(u8(mainIni.find.inputfindvk), 1000),
	inputfindvk2 = imgui.ImBuffer(u8(mainIni.find.inputfindvk2), 1000),
	inputfindvk3 = imgui.ImBuffer(u8(mainIni.find.inputfindvk3), 1000),
	inputfindvk4 = imgui.ImBuffer(u8(mainIni.find.inputfindvk4), 1000),
	inputfindvk5 = imgui.ImBuffer(u8(mainIni.find.inputfindvk5), 1000),
	inputfindvk6 = imgui.ImBuffer(u8(mainIni.find.inputfindvk6), 1000),
	inputfindvk7 = imgui.ImBuffer(u8(mainIni.find.inputfindvk7), 1000),
	inputfindvk8 = imgui.ImBuffer(u8(mainIni.find.inputfindvk8), 1000),
	inputfindvk9 = imgui.ImBuffer(u8(mainIni.find.inputfindvk9), 1000),
	inputfindvk10 = imgui.ImBuffer(u8(mainIni.find.inputfindvk10), 1000)
}
local eat = {
	checkmethod = imgui.ImInt(mainIni.eat.checkmethod),
	eat2met = imgui.ImInt(mainIni.eat.eat2met),
	cycwait = imgui.ImInt(mainIni.eat.cycwait),
	setmetod = imgui.ImInt(mainIni.eat.setmetod),
	eatmetod = imgui.ImInt(mainIni.eat.eatmetod),
	healstate = imgui.ImBool(mainIni.eat.healstate),
	hplvl = imgui.ImInt(mainIni.eat.hplvl),
	hpmetod = imgui.ImInt(mainIni.eat.hpmetod),
	arztextdrawid = imgui.ImInt(mainIni.eat.arztextdrawid),
	arztextdrawidheal = imgui.ImInt(mainIni.eat.arztextdrawidheal),
	drugsquen = imgui.ImInt(mainIni.eat.drugsquen)
}
-- one launch
local afksets = imgui.ImBool(false)
local showpass = false
local showtoken = false
local aopen = false
local opentimerid = {
	standart = -1,
	donate = -1,
	platina = -1,
	mask = -1,
	tainik = -1
}
local checkopen = {
	standart = false,
	donate = false,
	platina = false,
	mask = false,
	tainik = false
}
local onPlayerHungry = lua_thread.create_suspended(function()
	if eat.eatmetod.v == 1 then
		AFKMessage('��������, �����')
		gotoeatinhouse = true
		sampSendChat('/home')
	elseif eat.eatmetod.v == 3 then
		AFKMessage('��������, �����')
		setVirtualKeyDown(18, true)
		while not sampIsDialogActive() do wait(0) end
		sampSendDialogResponse(1825, 1, 6, false)
		while not sampIsDialogActive() do wait(0) end
		setVirtualKeyDown(18, true)
		while not sampIsDialogActive() do wait(0) end
		sampSendDialogResponse(1825, 1, 6, false)
		while not sampIsDialogActive() do wait(0) end
		wait(500)
		sampCloseCurrentDialogWithButton(0)
	elseif eat.eatmetod.v == 2 then 
		AFKMessage('��������, �����')
		if eat.setmetod.v == 0 then
			for i = 1,30 do
				sampSendChat('/cheeps')
				wait(4000)
			end    
		elseif eat.setmetod.v == 1 then
			for k = 1,10 do
				sampSendChat('/jfish')
				wait(3000)
			end    
		elseif eat.setmetod.v == 2 then
			sampSendChat('/jmeat')  
		elseif eat.setmetod.v == 3 then
			sampSendClickTextdraw(eat.arztextdrawid.v)
			sampSendClickTextdraw(eat.arztextdrawid.v)
		elseif eat.setmetod.v == 4 then
			sampSendChat('/meatbag') 
		end
	end
end)
local createscreen = lua_thread.create_suspended(function()
	wait(2000)
	takeScreen()
end)
local checkrulopen = lua_thread.create_suspended(function()
	while true do
		wait(0)
		if aopen then
			sampSendClickTextdraw(65535)
            wait(355)
            fix = true
            sampSendChat("/donate")
            wait(2000)
            fix = false
			AFKMessage('�������� ������ ��������')
			checkopen.standart = true
			checkopen.donate = roulette.donate.v and true or false
			checkopen.platina = roulette.platina.v and true or false
			checkopen.mask = roulette.mask.v and true or false
			checkopen.tainik = roulette.tainik.v and true or false
			sampSendChat('/invent')
			wait(roulette.wait.v*60000)
			AFKMessage('����������')
		end
	end
end)

--autofill
local file_accs = path .. "\\accs.json"

local dialogChecker = {
	check = false,
	id = -1,
	title = ""
}

local editpass = {
	numedit = -1,
	input = imgui.ImBuffer('',100)
}

local addnew = {
	name = imgui.ImBuffer('',100),
	pass = imgui.ImBuffer('',100),
	dialogid = imgui.ImInt(0),
	serverip = imgui.ImBuffer('',100)
}

function addnew:save()
	if #addnew.name.v > 0 and #addnew.pass.v > 0 and #(tostring(addnew.dialogid.v)) > 0 and #addnew.serverip.v > 0 then
		saveacc(addnew.name.v,addnew.pass.v,addnew.dialogid.v,addnew.serverip.v)
		return true
	end
end

local temppass = {}
local savepass = {}

if doesFileExist(file_accs) then
	local f = io.open(file_accs, "r")
	if f then
		savepass = decodeJson(f:read("a*"))
		f:close()
	end
end


local checklist = {
	u8('You are hungry!'),
	u8('������� ������')
}
local metod = {
	u8('�����'),
	u8('����'),
	u8('�������'),
	u8('TextDraw'),
	u8('�����')
}
local healmetod = {
	u8('�������'),
	u8('���������'),
	u8('����������'),
	u8('����'),
	u8('TextDraw'),
	u8('��������')
}
local aomethod = {
	u8('Xiaomi Mi 8'),
	u8('Huawei P20 PRO'),
	u8('Google Pixel 3'),
	u8('Samsung Galaxy S10'),
	u8('iPhone X')
}
 
font2 = renderCreateFont('Arial', 8, 5)
local list = {}
function list:new()
	return {
		pos = {
			x = select(1,getScreenResolution()) - 222,
			y = select(2,getScreenResolution()) - 60
		},
		size = {
			x = 200,
			y = 0
		}
	}
end
notfList = list:new()

function onWindowMessage(msg, wparam, lparam)
	if msg == 0x100 or msg == 0x101 then
		if (wparam == 0x1B and afksets.v) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			if msg == 0x101 then
				afksets.v = false
			end
		end
	end
end

menunum = 0 
menufill = 0 
localvalue = 0
local key, server, ts

function threadHandle(runner, url, args, resolve, reject) -- ��������� effil ������ ��� ����������
	local t = runner(url, args)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve(result) else reject(result) end
	elseif err then
		reject(err)
	elseif status == 'canceled' then
		reject(status)
	end
	t:cancel(0)
end
local function send_player_stream(id, i)
	if i then
		local bs = raknetNewBitStream()
		raknetBitStreamWriteInt16(bs, id)
		raknetBitStreamWriteInt8(bs, i[1])
		raknetBitStreamWriteInt32(bs, i[2])
		raknetBitStreamWriteFloat(bs, i[3].x)
		raknetBitStreamWriteFloat(bs, i[3].y)
		raknetBitStreamWriteFloat(bs, i[3].z)
		raknetBitStreamWriteFloat(bs, i[4])
		raknetBitStreamWriteInt32(bs, i[5])
		raknetBitStreamWriteInt8(bs, i[6])
		raknetEmulRpcReceiveBitStream(32, bs)
	end
end
function emul_rpc(hook, parameters)
    local bs_io = require 'samp.events.bitstream_io'
    local handler = require 'samp.events.handlers'
    local extra_types = require 'samp.events.extra_types'
    local hooks = {

        --[[ Outgoing rpcs
        ['onSendEnterVehicle'] = { 'int16', 'bool8', 26 },
        ['onSendClickPlayer'] = { 'int16', 'int8', 23 },
        ['onSendClientJoin'] = { 'int32', 'int8', 'string8', 'int32', 'string8', 'string8', 'int32', 25 },
        ['onSendEnterEditObject'] = { 'int32', 'int16', 'int32', 'vector3d', 27 },
        ['onSendCommand'] = { 'string32', 50 },
        ['onSendSpawn'] = { 52 },
        ['onSendDeathNotification'] = { 'int8', 'int16', 53 },
        ['onSendDialogResponse'] = { 'int16', 'int8', 'int16', 'string8', 62 },
        ['onSendClickTextDraw'] = { 'int16', 83 },
        ['onSendVehicleTuningNotification'] = { 'int32', 'int32', 'int32', 'int32', 96 },
        ['onSendChat'] = { 'string8', 101 },
        ['onSendClientCheckResponse'] = { 'int8', 'int32', 'int8', 103 },
        ['onSendVehicleDamaged'] = { 'int16', 'int32', 'int32', 'int8', 'int8', 106 },
        ['onSendEditAttachedObject'] = { 'int32', 'int32', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 116 },
        ['onSendEditObject'] = { 'bool', 'int16', 'int32', 'vector3d', 'vector3d', 117 },
        ['onSendInteriorChangeNotification'] = { 'int8', 118 },
        ['onSendMapMarker'] = { 'vector3d', 119 },
        ['onSendRequestClass'] = { 'int32', 128 },
        ['onSendRequestSpawn'] = { 129 },
        ['onSendPickedUpPickup'] = { 'int32', 131 },
        ['onSendMenuSelect'] = { 'int8', 132 },
        ['onSendVehicleDestroyed'] = { 'int16', 136 },
        ['onSendQuitMenu'] = { 140 },
        ['onSendExitVehicle'] = { 'int16', 154 },
        ['onSendUpdateScoresAndPings'] = { 155 },
        ['onSendGiveDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },
        ['onSendTakeDamage'] = { 'int16', 'float', 'int32', 'int32', 115 },]]

        -- Incoming rpcs
        ['onInitGame'] = { 139 },
        ['onPlayerJoin'] = { 'int16', 'int32', 'bool8', 'string8', 137 },
        ['onPlayerQuit'] = { 'int16', 'int8', 138 },
        ['onRequestClassResponse'] = { 'bool8', 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 128 },
        ['onRequestSpawnResponse'] = { 'bool8', 129 },
        ['onSetPlayerName'] = { 'int16', 'string8', 'bool8', 11 },
        ['onSetPlayerPos'] = { 'vector3d', 12 },
        ['onSetPlayerPosFindZ'] = { 'vector3d', 13 },
        ['onSetPlayerHealth'] = { 'float', 14 },
        ['onTogglePlayerControllable'] = { 'bool8', 15 },
        ['onPlaySound'] = { 'int32', 'vector3d', 16 },
        ['onSetWorldBounds'] = { 'float', 'float', 'float', 'float', 17 },
        ['onGivePlayerMoney'] = { 'int32', 18 },
        ['onSetPlayerFacingAngle'] = { 'float', 19 },
        --['onResetPlayerMoney'] = { 20 },
        --['onResetPlayerWeapons'] = { 21 },
        ['onGivePlayerWeapon'] = { 'int32', 'int32', 22 },
        --['onCancelEdit'] = { 28 },
        ['onSetPlayerTime'] = { 'int8', 'int8', 29 },
        ['onSetToggleClock'] = { 'bool8', 30 },
        ['onPlayerStreamIn'] = { 'int16', 'int8', 'int32', 'vector3d', 'float', 'int32', 'int8', 32 },
        ['onSetShopName'] = { 'string256', 33 },
        ['onSetPlayerSkillLevel'] = { 'int16', 'int32', 'int16', 34 },
        ['onSetPlayerDrunk'] = { 'int32', 35 },
        ['onCreate3DText'] = { 'int16', 'int32', 'vector3d', 'float', 'bool8', 'int16', 'int16', 'encodedString4096', 36 },
        --['onDisableCheckpoint'] = { 37 },
        ['onSetRaceCheckpoint'] = { 'int8', 'vector3d', 'vector3d', 'float', 38 },
        --['onDisableRaceCheckpoint'] = { 39 },
        --['onGamemodeRestart'] = { 40 },
        ['onPlayAudioStream'] = { 'string8', 'vector3d', 'float', 'bool8', 41 },
        --['onStopAudioStream'] = { 42 },
        ['onRemoveBuilding'] = { 'int32', 'vector3d', 'float', 43 },
        ['onCreateObject'] = { 44 },
        ['onSetObjectPosition'] = { 'int16', 'vector3d', 45 },
        ['onSetObjectRotation'] = { 'int16', 'vector3d', 46 },
        ['onDestroyObject'] = { 'int16', 47 },
        ['onPlayerDeathNotification'] = { 'int16', 'int16', 'int8', 55 },
        ['onSetMapIcon'] = { 'int8', 'vector3d', 'int8', 'int32', 'int8', 56 },
        ['onRemoveVehicleComponent'] = { 'int16', 'int16', 57 },
        ['onRemove3DTextLabel'] = { 'int16', 58 },
        ['onPlayerChatBubble'] = { 'int16', 'int32', 'float', 'int32', 'string8', 59 },
        ['onUpdateGlobalTimer'] = { 'int32', 60 },
        ['onShowDialog'] = { 'int16', 'int8', 'string8', 'string8', 'string8', 'encodedString4096', 61 },
        ['onDestroyPickup'] = { 'int32', 63 },
        ['onLinkVehicleToInterior'] = { 'int16', 'int8', 65 },
        ['onSetPlayerArmour'] = { 'float', 66 },
        ['onSetPlayerArmedWeapon'] = { 'int32', 67 },
        ['onSetSpawnInfo'] = { 'int8', 'int32', 'int8', 'vector3d', 'float', 'Int32Array3', 'Int32Array3', 68 },
        ['onSetPlayerTeam'] = { 'int16', 'int8', 69 },
        ['onPutPlayerInVehicle'] = { 'int16', 'int8', 70 },
        --['onRemovePlayerFromVehicle'] = { 71 },
        ['onSetPlayerColor'] = { 'int16', 'int32', 72 },
        ['onDisplayGameText'] = { 'int32', 'int32', 'string32', 73 },
        --['onForceClassSelection'] = { 74 },
        ['onAttachObjectToPlayer'] = { 'int16', 'int16', 'vector3d', 'vector3d', 75 },
        ['onInitMenu'] = { 76 },
        ['onShowMenu'] = { 'int8', 77 },
        ['onHideMenu'] = { 'int8', 78 },
        ['onCreateExplosion'] = { 'vector3d', 'int32', 'float', 79 },
        ['onShowPlayerNameTag'] = { 'int16', 'bool8', 80 },
        ['onAttachCameraToObject'] = { 'int16', 81 },
        ['onInterpolateCamera'] = { 'bool', 'vector3d', 'vector3d', 'int32', 'int8', 82 },
        ['onGangZoneStopFlash'] = { 'int16', 85 },
        ['onApplyPlayerAnimation'] = { 'int16', 'string8', 'string8', 'bool', 'bool', 'bool', 'bool', 'int32', 86 },
        ['onClearPlayerAnimation'] = { 'int16', 87 },
        ['onSetPlayerSpecialAction'] = { 'int8', 88 },
        ['onSetPlayerFightingStyle'] = { 'int16', 'int8', 89 },
        ['onSetPlayerVelocity'] = { 'vector3d', 90 },
        ['onSetVehicleVelocity'] = { 'bool8', 'vector3d', 91 },
        ['onServerMessage'] = { 'int32', 'string32', 93 },
        ['onSetWorldTime'] = { 'int8', 94 },
        ['onCreatePickup'] = { 'int32', 'int32', 'int32', 'vector3d', 95 },
        ['onMoveObject'] = { 'int16', 'vector3d', 'vector3d', 'float', 'vector3d', 99 },
        ['onEnableStuntBonus'] = { 'bool', 104 },
        ['onTextDrawSetString'] = { 'int16', 'string16', 105 },
        ['onSetCheckpoint'] = { 'vector3d', 'float', 107 },
        ['onCreateGangZone'] = { 'int16', 'vector2d', 'vector2d', 'int32', 108 },
        ['onPlayCrimeReport'] = { 'int16', 'int32', 'int32', 'int32', 'int32', 'vector3d', 112 },
        ['onGangZoneDestroy'] = { 'int16', 120 },
        ['onGangZoneFlash'] = { 'int16', 'int32', 121 },
        ['onStopObject'] = { 'int16', 122 },
        ['onSetVehicleNumberPlate'] = { 'int16', 'string8', 123 },
        ['onTogglePlayerSpectating'] = { 'bool32', 124 },
        ['onSpectatePlayer'] = { 'int16', 'int8', 126 },
        ['onSpectateVehicle'] = { 'int16', 'int8', 127 },
        ['onShowTextDraw'] = { 134 },
        ['onSetPlayerWantedLevel'] = { 'int8', 133 },
        ['onTextDrawHide'] = { 'int16', 135 },
        ['onRemoveMapIcon'] = { 'int8', 144 },
        ['onSetWeaponAmmo'] = { 'int8', 'int16', 145 },
        ['onSetGravity'] = { 'float', 146 },
        ['onSetVehicleHealth'] = { 'int16', 'float', 147 },
        ['onAttachTrailerToVehicle'] = { 'int16', 'int16', 148 },
        ['onDetachTrailerFromVehicle'] = { 'int16', 149 },
        ['onSetWeather'] = { 'int8', 152 },
        ['onSetPlayerSkin'] = { 'int32', 'int32', 153 },
        ['onSetInterior'] = { 'int8', 156 },
        ['onSetCameraPosition'] = { 'vector3d', 157 },
        ['onSetCameraLookAt'] = { 'vector3d', 'int8', 158 },
        ['onSetVehiclePosition'] = { 'int16', 'vector3d', 159 },
        ['onSetVehicleAngle'] = { 'int16', 'float', 160 },
        ['onSetVehicleParams'] = { 'int16', 'int16', 'bool8', 161 },
        --['onSetCameraBehind'] = { 162 },
        ['onChatMessage'] = { 'int16', 'string8', 101 },
        ['onConnectionRejected'] = { 'int8', 130 },
        ['onPlayerStreamOut'] = { 'int16', 163 },
        ['onVehicleStreamIn'] = { 164 },
        ['onVehicleStreamOut'] = { 'int16', 165 },
        ['onPlayerDeath'] = { 'int16', 166 },
        ['onPlayerEnterVehicle'] = { 'int16', 'int16', 'bool8', 26 },
        ['onUpdateScoresAndPings'] = { 'PlayerScorePingMap', 155 },
        ['onSetObjectMaterial'] = { 84 },
        ['onSetObjectMaterialText'] = { 84 },
        ['onSetVehicleParamsEx'] = { 'int16', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 'int8', 24 },
        ['onSetPlayerAttachedObject'] = { 'int16', 'int32', 'bool', 'int32', 'int32', 'vector3d', 'vector3d', 'vector3d', 'int32', 'int32', 113 }

    }
    local handler_hook = {
        ['onInitGame'] = true,
        ['onCreateObject'] = true,
        ['onInitMenu'] = true,
        ['onShowTextDraw'] = true,
        ['onVehicleStreamIn'] = true,
        ['onSetObjectMaterial'] = true,
        ['onSetObjectMaterialText'] = true
    }
    local extra = {
        ['PlayerScorePingMap'] = true,
        ['Int32Array3'] = true
    }
    local hook_table = hooks[hook]
    if hook_table then
        local bs = raknetNewBitStream()
        if not handler_hook[hook] then
            local max = #hook_table-1
            if max > 0 then
                for i = 1, max do
                    local p = hook_table[i]
                    if extra[p] then extra_types[p]['write'](bs, parameters[i])
                    else bs_io[p]['write'](bs, parameters[i]) end
                end
            end
        else
            if hook == 'onInitGame' then handler.on_init_game_writer(bs, parameters)
            elseif hook == 'onCreateObject' then handler.on_create_object_writer(bs, parameters)
            elseif hook == 'onInitMenu' then handler.on_init_menu_writer(bs, parameters)
            elseif hook == 'onShowTextDraw' then handler.on_show_textdraw_writer(bs, parameters)
            elseif hook == 'onVehicleStreamIn' then handler.on_vehicle_stream_in_writer(bs, parameters)
            elseif hook == 'onSetObjectMaterial' then handler.on_set_object_material_writer(bs, parameters, 1)
            elseif hook == 'onSetObjectMaterialText' then handler.on_set_object_material_writer(bs, parameters, 2) end
        end
        raknetEmulRpcReceiveBitStream(hook_table[#hook_table], bs)
        raknetDeleteBitStream(bs)
    end
end
function requestRunner() -- �������� effil ������ � �������� https �������
	return effil.thread(function(u, a)
		local https = require 'ssl.https'
		local ok, result = pcall(https.request, u, a)
		if ok then
			return {true, result}
		else
			return {false, result}
		end
	end)
end
function async_http_request(url, args, resolve, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
	lua_thread.create(threadHandle,runner, url, args, resolve, reject)
end
local vkerr, vkerrsend -- ��������� � ������� ������, nil ���� ��� ��
function tblfromstr(str)
	local a = {}
	for b in str:gmatch('%S+') do
		a[#a+1] = b
	end
	return a
end
function longpollResolve(result)
	if result then
		if not result:sub(1,1) == '{' then
			vkerr = '������!\n�������: ��� ���������� � VK!'
			return
		end
		local t = decodeJson(result)
		if t.failed then
			if t.failed == 1 then
				ts = t.ts
			else
				key = nil
				longpollGetKey()
			end
			return
		end
		if t.ts then
			ts = t.ts
		end
		if vknotf.state.v and t.updates then
			for k, v in ipairs(t.updates) do
				if v.type == 'message_new' and tonumber(v.object.from_id) == tonumber(vknotf.user_id.v) and v.object.text then
					if v.object.payload then
						local pl = decodeJson(v.object.payload)
						if pl.button then
							if pl.button == 'getstats' then
								getPlayerArzStats(sendvknotf)
							elseif pl.button == 'getinfo' then
								getPlayerInfo(sendvknotf)
							elseif pl.button == 'gethun' then
								getPlayerArzHun(sendvknotf)
							elseif pl.button == 'lastchat10' then
								lastchatmessage(10,sendvknotf)
							elseif pl.button == 'support' then
								sendvknotf('�������:\n!send - ��������� ��������� �� VK � ����\n!getplstats - �������� ���������� ���������\n!getplhun - �������� ����� ���������\n!getplinfo - �������� ���������� � ���������\n!sendcode - ��������� ��� � �����\n!sendvk - ��������� ��� �� ��\n!gauth - ��������� ��� �� GAuth\n!p/!h - ��������/������� �����\n!d [����� ��� �����] - �������� �� ���������� ����\n!dc - ������� ������\n!screen - ������� �������� (����������� ��������� !helpscreen)\n!helpscreen - ������ �� ������� !screen\n���������: @sk33z')
							elseif pl.button == 'openchest' then
								openchestrulletVK(sendvknotf)
							elseif pl.button == 'activedia' then
								sendDialog(sendvknotf)
							elseif pl.button == 'keyboardkey' then
								sendkeyboradkey()
							elseif pl.button == 'offkey' then
								sendoff()
							elseif pl.button == 'screenkey' then
								sendscreen()
							elseif pl.button == 'keyW' then
								setKeyFromVK('go',sendvknotf)
							elseif pl.button == 'keyA' then
								setKeyFromVK('left',sendvknotf)
							elseif pl.button == 'keyS' then
								setKeyFromVK('back',sendvknotf)
							elseif pl.button == 'keyD' then
								setKeyFromVK('right',sendvknotf)
							elseif pl.button == 'keyALT' then
								sendkeyALT()
							elseif pl.button == 'keyESC' then
								sendkeyESC()
							elseif pl.button == 'primary_dialog' then
								sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, -1)
								sampCloseCurrentDialogWithButton(0)
							elseif pl.button == 'secondary_dialog' then
								sampSendDialogResponse(sampGetCurrentDialogId(), 0, -1, -1)
								sampCloseCurrentDialogWithButton(0)
							elseif pl.button == 'offgame' then
								sendvknotf('�������� ����')
								wait(1000)
								os.execute("taskkill /f /im gta_sa.exe")
							elseif pl.button == 'offpc' then
								os.execute("shutdown -s -t 30")
								sendvknotf('��������� ����� �������� ����� 30 ������.')
							elseif pl.button == 'phonedown' then
								PickDownPhone()
							elseif pl.button == 'phoneup' then
								PickUpPhone()
							end
						end
						return
					end
					local objsend = tblfromstr(v.object.text)
					local diasend = v.object.text .. ' '
					if objsend[1] == '!getplstats' then
						getPlayerArzStats()
					elseif objsend[1] == '!getplinfo' then
						getPlayerInfo()
					elseif objsend[1] == '!getplhun' then
						getPlayerArzHun()
					elseif objsend[1] == '!p' then
						PickUpPhone()
					elseif objsend[1] == '!h' then
						PickDownPhone()
					elseif objsend[1] == '!screen' then
						sendscreen()
					elseif objsend[1] == '!helpscreen' then
						sendhelpscreen()
					elseif objsend[1] == '!send' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampProcessChatInput(args)
							sendvknotf('��������� "' .. args .. '" ���� ������� ���������� � ����')
						else
							sendvknotf('������������ ��������! ������: !send [������]')
						end
					elseif objsend[1] == '!sendcode' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampSendDialogResponse(8928, 1, false, (args))
							sendvknotf('��� "' .. args .. '" ��� ������� ��������� � ������')
						else
							sendvknotf('������������ ��������! ������: !sendcode [���]')
					end
					elseif objsend[1] == '!sendvk' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampSendDialogResponse(7782, 1, false, (args))
							sendvknotf('��� "' .. args .. '" ��� ������� ��������� � ������')
						else
							sendvknotf('������������ ��������! ������: !sendvk [���]')
					end
					elseif objsend[1] == '!gauth' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampSendDialogResponse(8929, 1, false, (args))
							sendvknotf('��� "' .. args .. '" ��� ������� ��������� � ������')
						else
							sendvknotf('������������ ��������! ������: !gauth [���]')
					end
					elseif diasend:match('^!d ') then
						diasend = diasend:sub(1, diasend:len() - 1)
						local style = sampGetCurrentDialogType()
						if style == 2 or style > 3 and diasend:match('^!d (%d*)') then
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, tonumber(u8:decode(diasend:match('^!d (%d*)'))) - 1, -1)
						elseif style == 1 or style == 3 then
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, u8:decode(diasend:match('^!d (.*)')))
						else
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, -1) -- ��
						end
						closeDialog()
					elseif diasend:match('^!dc ') then
						sampSendDialogResponse(sampGetCurrentDialogId(), 0, -1, -1) -- ���
						sampCloseCurrentDialogWithButton(0)
					else
						if diasend and diasend:sub(1, 1) == '/' then
							diasend = diasend:sub(1, diasend:len() - 1)
							sampProcessChatInput(u8:decode(diasend))
						end
						return
					end

				end
			end
		end
	end
end
function longpollGetKey()
	async_http_request('https://api.vk.com/method/groups.getLongPollServer?group_id=' .. vknotf.group_id.v .. '&access_token=' .. vknotf.token.v .. '&v=5.81', '', function (result)
		if result then
			if not result:sub(1,1) == '{' then
				vkerr = '������!\n�������: ��� ���������� � VK!'
				return
			end
			local t = decodeJson(result)
			if t then
				if t.error then
					vkerr = '������!\n���: ' .. t.error.error_code .. ' �������: ' .. t.error.error_msg
					return
				end
				server = t.response.server
				ts = t.response.ts
				key = t.response.key
				vkerr = nil
			end
		end
	end)
end
function sendvknotf(msg, host)
	host = host or sampGetCurrentServerName()
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
	msg = msg:gsub('{......}', '')
	msg = '[AFK Tools | Notifications | '..acc..' | '..host..']\n'..msg
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = vkKeyboard()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if vknotf.state.v and #vknotf.user_id.v > 0 then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. vknotf.user_id.v .. '&message=' .. msg .. '&access_token=' .. vknotf.token.v .. '&v=5.81',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = '������!\n���: ' .. t.error.error_code .. ' �������: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function sendvknotfv2(msg)
	msg = msg:gsub('{......}', '')
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = vkKeyboard2()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if vknotf.state.v and vknotf.user_id.v ~= '' then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. vknotf.user_id.v .. '&message=' .. msg .. '&access_token=' .. vknotf.token.v .. '&v=5.81',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = '������!\n���: ' .. t.error.error_code .. ' �������: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function sendoffpcgame(msg)
	msg = msg:gsub('{......}', '')
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = offboard()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if vknotf.state.v and vknotf.user_id.v ~= '' then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. vknotf.user_id.v .. '&message=' .. msg .. '&access_token=' .. vknotf.token.v .. '&v=5.81',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = '������!\n���: ' .. t.error.error_code .. ' �������: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function sendphonekey(msg)
	msg = msg:gsub('{......}', '')
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = phonekey()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if vknotf.state.v and vknotf.user_id.v ~= '' then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. vknotf.user_id.v .. '&message=' .. msg .. '&access_token=' .. vknotf.token.v .. '&v=5.81',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = '������!\n���: ' .. t.error.error_code .. ' �������: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function senddialog2(msg)
	msg = msg:gsub('{......}', '')
	msg = u8(msg)
	msg = url_encode(msg)
	local keyboard = dialogkey()
	keyboard = u8(keyboard)
	keyboard = url_encode(keyboard)
	msg = msg .. '&keyboard=' .. keyboard
	if vknotf.state.v and vknotf.user_id.v ~= '' then
		async_http_request('https://api.vk.com/method/messages.send', 'user_id=' .. vknotf.user_id.v .. '&message=' .. msg .. '&access_token=' .. vknotf.token.v .. '&v=5.81',
		function (result)
			local t = decodeJson(result)
			if not t then
				return
			end
			if t.error then
				vkerrsend = '������!\n���: ' .. t.error.error_code .. ' �������: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function getOnline()
	local countvers = 0
	for i = 0, 999 do
		if sampIsPlayerConnected(i) then
			countvers = countvers + 1
		end
	end
	return countvers
end
function vkKeyboard() --������� ���������� ���������� ��� ���� VK, ��� ������� ��� ����� ����� ������� ���� �� �����������
	local keyboard = {}
	keyboard.one_time = false
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
	local row = keyboard.buttons[1]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "getinfo"}'
	row[1].action.label = '����������'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "getstats"}'
	row[2].action.label = '����������'
	row[3] = {}
	row[3].action = {}
	row[3].color = 'positive'
	row[3].action.type = 'text'
	row[3].action.payload = '{"button": "gethun"}'
	row[3].action.label = '�����'
	keyboard.buttons[2] = {} -- ������ ������ ������
	row = keyboard.buttons[2]
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "lastchat10"}'
	row[2].action.label = '��������� 10 ����� � ����'
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "openchest"}'
	row[1].action.label = aopen and '��������� ������������' or '�������� ������������'
	keyboard.buttons[3] = {} -- ������ ������ ������
	row = keyboard.buttons[3]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "activedia"}'
	row[1].action.label = activedia and '�� ���������� �������' or '���������� �������'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "support"}'
	row[2].action.label = '���������'
	keyboard.buttons[4] = {} -- ������ ������ ������
	row = keyboard.buttons[4]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'primary'
	row[1].action.type = 'text'
    row[1].action.payload = '{"button": "offkey"}'
	row[1].action.label = '���������� &#128163;'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'primary'
	row[2].action.type = 'text'
    row[2].action.payload = '{"button": "keyboardkey"}'
	row[2].action.label = '���������� &#9000;'
	keyboard.buttons[5] = {} -- ������ ������ ������
	row = keyboard.buttons[5]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'primary'
	row[1].action.type = 'text'
    row[1].action.payload = '{"button": "screenkey"}'
	row[1].action.label = '��������'
	return encodeJson(keyboard)
end
function sendkeyboradkey()
	vkKeyboard2()
	sendvknotfv2('������� ���������� �����')
end
function vkKeyboard2() --������� ���������� ���������� ��� ���� VK, ��� ������� ��� ����� ����� ������� ���� �� �����������
	local keyboard = {}
	keyboard.inline = true
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
	local row = keyboard.buttons[1]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'negative'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "primary_dialog"}'
	row[1].action.label = 'OK'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "keyW"}'
	row[2].action.label = 'W'
	row[3] = {}
	row[3].action = {}
	row[3].color = 'negative'
	row[3].action.type = 'text'
    row[3].action.payload = '{"button": "secondary_dialog"}'
	row[3].action.label = 'Cancel'
	row[4] = {}
	row[4].action = {}
	row[4].color = 'negative'
	row[4].action.type = 'text'
    row[4].action.payload = '{"button": "keyALT"}'
	row[4].action.label = 'ALT'
	keyboard.buttons[2] = {} -- ������ ������ ������
	row = keyboard.buttons[2]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "keyA"}'
	row[1].action.label = 'A'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "keyS"}'
	row[2].action.label = 'S'
	row[3] = {}
	row[3].action = {}
	row[3].color = 'positive'
	row[3].action.type = 'text'
	row[3].action.payload = '{"button": "keyD"}'
	row[3].action.label = 'D'
	row[4] = {}
	row[4].action = {}
	row[4].color = 'negative'
	row[4].action.type = 'text'
	row[4].action.payload = '{"button": "keyESC"}'
	row[4].action.label = 'ESC'
	return encodeJson(keyboard)
end
function sendoff()
	offboard()
	sendoffpcgame('��� �� ������ ���������?')
end
function sendphonecall()
	phonekey()
	sendphonekey('��� ������! �������� ��������.')
end
function offboard() --������� ���������� ���������� ��� ���� VK, ��� ������� ��� ����� ����� ������� ���� �� �����������
	local keyboard = {}
	keyboard.inline = true
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
	local row = keyboard.buttons[1]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'negative'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "offpc"}'
	row[1].action.label = '���������'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "offgame"}'
	row[2].action.label = '������� ����'
	return encodeJson(keyboard)
end
function phonekey() --������� ���������� ���������� ��� ���� VK, ��� ������� ��� ����� ����� ������� ���� �� �����������
	local keyboard = {}
	keyboard.inline = true
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
	local row = keyboard.buttons[1]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'negative'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "phonedown"}'
	row[1].action.label = '���������'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "phoneup"}'
	row[2].action.label = '�������'
	return encodeJson(keyboard)
end
function dialogkey() --������� ���������� ���������� ��� ���� VK, ��� ������� ��� ����� ����� ������� ���� �� �����������
	local keyboard = {}
	keyboard.inline = true
	keyboard.buttons = {}
	keyboard.buttons[1] = {}
	local row = keyboard.buttons[1]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "primary_dialog"}'
	row[1].action.label = 'Enter'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'negative'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "secondary_dialog"}'
	row[2].action.label = 'ESC'
	return encodeJson(keyboard)
end
function char_to_hex(str)
	return string.format("%%%02X", string.byte(str))
  end

function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end
function getPlayerInfo()
	if isSampLoaded() and isSampAvailable() and sampGetGamestate() == 3 then
		local response = ''
		response = response .. 'HP: ' .. getCharHealth(PLAYER_PED) .. '\n'
		response = response .. 'Armor: ' .. getCharArmour(PLAYER_PED) .. '\n'
		response = response .. 'Money: ' .. getPlayerMoney(PLAYER_HANDLE) .. '\n'
		response = response .. 'Online: ' .. getOnline() .. '\n'
		local x, y, z = getCharCoordinates(PLAYER_PED)
		response = response .. 'Coords: X: ' .. math.floor(x) .. ' | Y: ' .. math.floor(y) .. ' | Z: ' .. math.floor(z)
		sendvknotf(response)
	else
		sendvknotf('�� �� ���������� � �������!')
	end
end
sendstatsstate = false
function getPlayerArzStats()
	if sampIsLocalPlayerSpawned() then
		sendstatsstate = true
		sampSendChat('/stats')
		local timesendrequest = os.clock()
		while os.clock() - timesendrequest <= 10 do
			wait(0)
			if sendstatsstate ~= true then
				timesendrequest = 0
			end 
		end
		if not vknotf.dienable.v then sendvknotf(sendstatsstate == true and '������! � ������� 10 ������ ������ �� ������� ����������!' or tostring(sendstatsstate)) end
		sendstatsstate = false
	else
		sendvknotf('(error) �������� �� ���������')
	end
end
function lastchatmessage(intchat, tochat)
	if sampIsLocalPlayerSpawned() then
		print('use: lastchat')
		local allchat = '\n'
		for i = 100-intchat, 99 do
			local getstr = select(1,sampGetChatString(i))
			allchat = allchat .. getstr .. '\n'
		end
		sendvknotf(allchat)
	else
		sendvknotf('(error) �������� �� ���������')
	end
end
function getPlayerArzHun()
	if sampIsLocalPlayerSpawned() then
		gethunstate = true
		sampSendChat('/satiety')
		local timesendrequest = os.clock()
		while os.clock() - timesendrequest <= 10 do
			wait(0)
			if gethunstate ~= true then
				timesendrequest = 0
			end 
		end
		if not vknotf.dienable.v then sendvknotf(gethunstate == true and '������! � ������� 10 ������ ������ �� ������� ����������!' or tostring(gethunstate)) end
		gethunstate = false
	else
		sendvknotf('(error) �������� �� ���������')
	end
end
function randomInt() 
    math.randomseed(os.time() + os.clock())
    return math.random(-2147483648, 2147483648)
end 
function sendhelpscreen()
	sendvknotf('���������� �� ������� ������� "!screen":\n\n������� !screen �������� ��������� �������:\n� ���� ���� ������� - ���������� ���� �������\n� ���� ���� �� ���� ����� - ����� ������ ����� ��������.\n� ����� ��������� �������� - ����� ������� ���� � ������� ����� � ��������� �� ���� ����� (�� �������� ����� ������ � ���������� �������� �������� ������� �����).\n� ��� ������ ������� ����� ������� ����������� ���������� (������� ����� � ���� VK Notifications)')
end
function sendscreen()
	if vknotf.state.v then 
	local d3dx9_43 = ffi.load('d3dx9_43.dll')
    local pDevice = ffi.cast("struct d3ddevice*", 0xC97C28)
    local CreateOffscreenPlainSurface =  ffi.cast("long(__stdcall*)(void*, unsigned long, unsigned long, unsigned long, unsigned long, void**, void*)", pDevice.vtbl[0].CreateOffscreenPlainSurface)
    local GetFrontBufferData =  ffi.cast("long(__stdcall*)(void*, unsigned long, void*)", pDevice.vtbl[0].GetFrontBufferData)
    local pSurface = ffi.cast("void**", ffi.new('unsigned long[1]'))
    local sx = ffi.C.GetSystemMetrics(0);
    local sy = ffi.C.GetSystemMetrics(1);
    CreateOffscreenPlainSurface(pDevice, sx, sy, 21, 3, pSurface, ffi.cast("void*", 0))
    if GetFrontBufferData(pDevice, 0, pSurface[0]) < 0 then
    else
        local Point = ffi.new("struct POINT[1]")
        local Rect = ffi.new("struct RECT[1]")
        local HWND = ffi.cast("int*", 0xC97C1C)[0]
        ffi.C.ClientToScreen(HWND, Point)
        ffi.C.GetClientRect(HWND, Rect)
        Rect[0].left = Rect[0].left + Point[0].x
        Rect[0].right = Rect[0].right + Point[0].x
        Rect[0].top = Rect[0].top + Point[0].y
        Rect[0].bottom = Rect[0].bottom + Point[0].y
        d3dx9_43.D3DXSaveSurfaceToFileA("1.png", 3, pSurface[0], ffi.cast("void*", 0), Rect) -- second parameter(3) is D3DXIMAGE_FILEFORMAT, checkout https://docs.microsoft.com/en-us/windows/win32/direct3d9/d3dximage-fileformat
        sendPhoto(getGameDirectory()..'/1.png') -- �������� ����� ����� ������
		end
	end
end
function uploadPhoto(filename, uploadUrl) 
	if vknotf.state.v then 
    local fileHandle = io.open(filename,"rb") 
    if (fileHandle) then 
      local fileContent = fileHandle:read( "*a" )
      fileHandle:close()
      local boundary = 'abcd'
      local header_b = 'Content-Disposition: form-data; name="file"; filename="' .. filename .. '"\r\nContent-Type: image/png\r\n'
      local fileContent =  '--' ..boundary .. '\r\n' ..header_b ..'\r\n'.. fileContent .. '\r\n--' .. boundary ..'--\r\n'
      local resp = requests.post(uploadUrl, {
        headers = {
          ["Content-Length"] =  fileContent:len(), 
          ['Content-Type'] = 'multipart/form-data; boundary=' .. boundary    
        },
        data = fileContent
      })
      return resp.json()
		end
    end
end
function sendPhoto(path) 
	if vknotf.state.v then 
    local upResponse = requests.post(("https://api.vk.com/method/photos.getMessagesUploadServer?peer_id=%d&access_token=%s&v=5.131"):format(vknotf.user_id.v, vknotf.token.v)).json()
    local uploadedResponse = uploadPhoto(path, upResponse.response.upload_url)
    local saveResponse = requests.post(("https://api.vk.com/method/photos.saveMessagesPhoto?server=%d&photo=%s&hash=%s&access_token=%s&v=5.131"):format(uploadedResponse.server,uploadedResponse.photo,uploadedResponse.hash, vknotf.token.v)).json()
    local image = saveResponse.response[1]
    local att_image = ("photo%d_%d_%s"):format(image.owner_id, image.id, image.access_key)
    os.remove(getGameDirectory()..'/1.png') -- �������� ����� � ���� ����� 
    return requests.post(("https://api.vk.com/method/messages.send?peer_id=%d&attachment=%s&access_token=%s&random_id=%d&v=5.131"):format(vknotf.user_id.v, att_image, vknotf.token.v, randomInt()))
	end
end
function PickUpPhone()
	if sampIsLocalPlayerSpawned() then
		setVirtualKeyDown(89, true)
		setVirtualKeyDown(89, false)
		if aphone.v == 0 then -- xiaomi
			sampSendClickTextdraw(2105)
		end
		if aphone.v == 1 then -- huawei
			sampSendClickTextdraw(2106)
		end
		if aphone.v == 2 then -- pixel
			sampSendClickTextdraw(2103)
		end
		if aphone.v == 3 then -- samsung
			sampSendClickTextdraw(2108)
		end
		if aphone.v == 4 then -- iphone
			sampSendClickTextdraw(2109)
		end
	end
end
function sendkeyALT()
	setVirtualKeyDown(18, true)
	setVirtualKeyDown(18, false)
end
function sendkeyESC()
	sampSendClickTextdraw(65535)
end
function PickDownPhone()
	if sampIsLocalPlayerSpawned() then
		setVirtualKeyDown(89, true)
		setVirtualKeyDown(89, false)
		if aphone.v == 0 then -- xiaomi
			sampSendClickTextdraw(2101)
		end
		if aphone.v == 1 then -- huawei
			sampSendClickTextdraw(2102)
		end
		if aphone.v == 2 then -- pixel
			sampSendClickTextdraw(2099)
		end
		if aphone.v == 3 then -- samsung
			sampSendClickTextdraw(2104)
		end
		if aphone.v == 4 then -- iphone
			sampSendClickTextdraw(2105)
		end
	end
end
function setKeyFromVK(getkey)
	if isSampLoaded() and isSampAvailable() and sampIsLocalPlayerSpawned() then
		sendvknotf('���������� ������� �� ������� '..getkey)
		local timepress = os.time()
		if getkey == 'go' then
			print('key set go')
			while os.time() - timepress < 2 do wait(0) setGameKeyState(1,-1024) end
			setGameKeyState(1,0)
		elseif getkey == 'back' then
			print('key set back')
			while os.time() - timepress < 2 do wait(0) setGameKeyState(1,1024) end
			setGameKeyState(1,0)
		elseif getkey == 'left' then
			print('key set left')
			while os.time() - timepress < 2 do wait(0) setGameKeyState(0,-1024) end
			setGameKeyState(0,0)
		elseif getkey == 'right' then
			print('key set right')
			while os.time() - timepress < 2 do wait(0) setGameKeyState(0,1024) end
			setGameKeyState(0,0)
		end
	else
		sendvknotf('��� �������� �� ���������!')
	end
end
function openchestrulletVK()
	if isSampLoaded() and isSampAvailable() and sampIsLocalPlayerSpawned() then
		if roulette.standart.v or roulette.donate.v or roulette.platina.v or roulette.mask.v or roulette.tainik.v then
			aopen = not aopen
			if aopen then 
				checkrulopen:run()
				afksets.v = false
			else 
				lua_thread.terminate(checkrulopen) 
			end
			sendvknotf('������������ '..(aopen and '��������!' or '���������!'))
		else
			sendvknotf("�������� ������ � ���������!")
		end
	else
		sendvknotf('��� �������� �� ���������!')
	end
end
function sendDialog()
	activedia = not activedia
	if activedia then 
	vknotf.dienable.v = true
	sendvknotf('�������� �������� � VK ��������.')
	else
	vknotf.dienable.v = false
	sendvknotf('�������� �������� � VK ���������.')
	end
end
function openchestrullet()
	if sampIsLocalPlayerSpawned() then
		if roulette.standart.v or roulette.donate.v or roulette.platina.v or roulette.mask.v or roulette.tainik.v then
			aopen = not aopen
			AFKMessage('������������ '..(aopen and '��������!' or '���������!'))
			if aopen then 
				checkrulopen:run()
				afksets.v = false
			else 
				lua_thread.terminate(checkrulopen) 
			end
		else
			AFKMessage("�������� ������ � ���������!")
		end
	else
		AFKMessage("��� �������� �� ���������!")
	end
end
bizpiaron = false
idsshow = false
function vkget()
	longpollGetKey()
	local reject, args = function() end, ''
	while not key do 
		wait(1)
	end
	local runner = requestRunner()
	while true do
		while not key do wait(0) end
		url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25' --������ url ������ ����� ������ �����a, ��� ��� server/key/ts ����� ����������
		threadHandle(runner, url, args, longpollResolve, reject)
		wait(100)
	end
end
function bizpiar()
	while true do wait(0)
		if bizpiaron then
			sampSendChat(u8:decode(piar.piar1.v))
			vknotf.dienable.v = false
			wait(5000)
			vknotf.dienable.v = true
			wait(piar.piarwait.v * 1000)
		end
	end
end
function bizpiar2()
	while true do wait(0)
		if bizpiaron then
			if piar.piar2.v:len() > 0 then
				sampSendChat(u8:decode(piar.piar2.v))
				vknotf.dienable.v = false
				wait(5000)
				vknotf.dienable.v = true
				wait(piar.piarwait2.v * 1000)
			end
		end
	end
end
function bizpiar3()
	while true do wait(0)
		if bizpiaron then
			if piar.piar3.v:len() > 0 then
				sampSendChat(u8:decode(piar.piar3.v))
				vknotf.dienable.v = false
				wait(5000)
				vknotf.dienable.v = true
				wait(piar.piarwait3.v * 1000)
			end
		end
	end
end
bizpiarhandle = lua_thread.create_suspended(bizpiar) 
bizpiarhandle2 = lua_thread.create_suspended(bizpiar2) 
bizpiarhandle3 = lua_thread.create_suspended(bizpiar3) 
function activatePiar(bbiza)
	if bbiza then 
		bizpiarhandle:run()
		bizpiarhandle2:run()
		bizpiarhandle3:run()
	else 
		bizpiarhandle:terminate()
		bizpiarhandle2:terminate()
		bizpiarhandle3:terminate()
	end
end

function main()
    while not isSampAvailable() do
        wait(0)
	end
	if piar.auto_piar.v and (os.time() - piar.last_time) <= piar.auto_piar_kd.v then
		lua_thread.create(function()
			while not sampIsLocalPlayerSpawned() do wait(0) end
			bizpiaron = true
			activatePiar(bizpiaron)
			AFKMessage('[��������] ���� ������� �.� ������ ������ ��� '..piar.auto_piar_kd.v..' ������ ����� ��������� ��������')
		end)
	end
	local _a = [[������ ������� �������!
������: %s
������� ����: /afktools
������: bakhusse x mamashin.]]
	if autoupdateState.v then
		updates:autoupdate()
	else
		updates:getlast()
	end
	AFKMessage(_a:format(thisScript().version))
	sampRegisterChatCommand('eattest',function() gotoeatinhouse = true; sampSendChat('/home') end)
	sampRegisterChatCommand('afktools',function() afksets.v = not afksets.v end)
	sampRegisterChatCommand('afkreload',function() thisScript():reload() end)
	sampRegisterChatCommand('afkunload',function() thisScript():unload() end)
	sampRegisterChatCommand('afksrec', function() 
		if handle_aurc then
			handle_aurc:terminate()
			handle_aurc = nil
			AFKMessage('������������� ����������!')
		else
			AFKMessage('�� ������ �� �������� ��������������!')
		end
		if handle_rc then
			handle_rc:terminate()
			handle_rc = nil
			AFKMessage('��������� ����������!')
		else
			AFKMessage('�� ������ �� �������� ����������!')
		end
	end)
	sampRegisterChatCommand('afkrec',function(a)
		a = a and (tonumber(a) and tonumber(a) or 1) or 1
		reconstandart(a)
	end)
	if fastconnect.v then
		sampFastConnect(fastconnect.v)
	end
	workpaus(antiafk.v)
	lua_thread.create(vkget)
    while true do 
		wait(0)
        imgui.Process = afksets.v or #_message>0
		imgui.ShowCursor = afksets.v
		if idsshow then
            local alltextdraws = sampGetAllTextDraws()
            for _, v in pairs(alltextdraws) do
                local fX,fY = sampTextdrawGetPos(v)
                local fX,fY = convertGameScreenCoordsToWindowScreenCoords(fX,fY)	
                renderFontDrawText(font2,tostring(v),tonumber(fX),tonumber(fY),0xD7FFFFFF)
            end
		end
    end
end
function convertHexToImVec4(hex,alp)
	alp = alp or 255 
	local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	return imgui.ImVec4(r/255,g/255,b/255,alp/255)
end
function convertImVec4ToU32(imvec)
	return imgui.ImColor(imvec):GetU32()
end
--������ ������
function onRenderNotification()
	local count = 0
	for k, v in ipairs(_message) do
		local push = false
		if v.active and v.time < os.clock() then
			v.active = false
			table.remove(_message, k)
		end
		if count < 10 then
			if not v.active then
				if v.showtime > 0 then
					v.active = true
					v.time = os.clock() + v.showtime
					v.showtime = 0
				end
			end
			if v.active then
				count = count + 1
				if v.time + 3.000 >= os.clock() then
					imgui.PushStyleVar(imgui.StyleVar.Alpha, (v.time - os.clock()) / 0.3)
					push = true
				end
				local nText = u8(tostring(v.text))
				notfList.size = imgui.GetFont():CalcTextSizeA(imgui.GetFont().FontSize, 200.0, 196.0, nText)
				notfList.pos = imgui.ImVec2(notfList.pos.x, (notfList.pos.y - (count == 1 and notfList.size.y or (notfList.size.y + 40))))
				imgui.SetNextWindowPos(notfList.pos, _, imgui.ImVec2(0.0, 0.0))
				imgui.SetNextWindowSize(imgui.ImVec2(200, notfList.size.y + imgui.GetStyle().ItemSpacing.y + imgui.GetStyle().WindowPadding.y+25))
				imgui.Begin(u8'##msg' .. k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
				imgui.CenterText('AFK Tools')
				imgui.Separator()
				imgui.TextWrapped(nText)
				imgui.End()
				if push then
					imgui.PopStyleVar()
				end
			end
		end
	end
	notfList = list:new()
end
--imgui: �������� �����
function autofillelementsaccs()
	if imgui.Button(u8('��������� ������')) then menufill = 1 end
	imgui.SameLine()
	if imgui.Button(u8('�������� �������')) then
		imgui.OpenPopup('##addacc')
	end
	if imgui.BeginPopupModal('##addacc',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.CenterText(u8('�������� ����� �������'))
		imgui.Separator()
		imgui.CenterText(u8('���'))
		imgui.Separator()
		imgui.InputText('##nameadd',addnew.name)
		imgui.Separator()
		imgui.CenterText(u8('������'))
		imgui.Separator()
		imgui.InputText('##addpas',addnew.pass)
		imgui.Separator()
		imgui.CenterText(u8('ID �������'))
		imgui.SameLine()
		imgui.TextQuestion(u8('ID ������� � ������� ���� ������ ������\n��������� ID ��� Arizona RP\n	2 - ������ ����� ������\n	991 - ������ PIN-���� �����'))
		imgui.Separator()
		imgui.InputInt('##dialogudadd',addnew.dialogid)
		imgui.Separator()
		imgui.CenterText(u8('IP �������'))
		imgui.SameLine()
		imgui.TextQuestion(u8('IP �������, �� ������� ����� ������ ������\n������: 185.169.134.171:7777'))
		imgui.Separator()
		imgui.InputText('##ipport',addnew.serverip)
		imgui.Separator()
		if imgui.Button(u8("��������"), imgui.ImVec2(-1, 20)) then
			if addnew:save() then
				imgui.CloseCurrentPopup()
			end
		end
		if imgui.Button(u8("�������"), imgui.ImVec2(-1, 20)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	imgui.SameLine()
	imgui.Checkbox(u8('��������'),autologin.state); imgui.SameLine(); imgui.TextQuestion(u8('�������� �������������� � �������'))
	imgui.SameLine()
	imgui.CenterText(u8'��������������'); imgui.SameLine()
	imgui.SameLine(838)
	if imgui.Button(u8('��������')) then
		local f = io.open(file_accs, "r")
		if f then
			savepass = decodeJson(f:read("a*"))
			f:close()
		end
		AFKMessage('����������� ����� ������')
	end
	imgui.Columns(3, _, true)
	imgui.Separator()
	imgui.SetColumnWidth(-1, 150); imgui.Text(u8"   �������"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 150); imgui.Text(u8"������"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 450); imgui.Text(u8"������"); imgui.NextColumn()
	for k, v in pairs(savepass) do
		imgui.Separator()
		if imgui.Selectable(u8('   '..v[1]..'##'..k), false, imgui.SelectableFlags.SpanAllColumns) then imgui.OpenPopup('##acc'..k) end
		if imgui.BeginPopupModal('##acc'..k,true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			btnWidth2 = (imgui.GetWindowWidth() - 22)/2
			imgui.CreatePaddingY(8)
			imgui.CenterText(u8('������� '..v[1]))
			imgui.Separator()
			for f,t in pairs(v[3]) do
				imgui.Text(u8('������[ID]: '..v[3][f].id..' �������� ������: '..v[3][f].text))
				if editpass.numedit == f then
					imgui.PushItemWidth(-1)
					imgui.InputText(u8'##pass'..f,editpass.input)
					imgui.PopItemWidth()
					if imgui.Button(u8("�����������##"..f), imgui.ImVec2(-1, 20)) then
						v[3][f].text = editpass.input.v
						editpass.input.v = ''
						editpass.numedit = -1
						saveaccounts()
					end
				elseif editpass.numedit == -1 then
					if imgui.Button(u8("������� ������##2"..f), imgui.ImVec2(-1, 20)) then
						editpass.input.v = v[3][f].text
						editpass.numedit = f
					end
				end
				if imgui.Button(u8("�����������##"..f), imgui.ImVec2(btnWidth2, 0)) then
					setClipboardText(v[3][f].text)
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if imgui.Button(u8("�������##"..f), imgui.ImVec2(btnWidth2, 0)) then
					v[3][f] = nil
					if #v[3] == 0 then
						savepass[k] = nil
					end
					saveaccounts()
				end
				imgui.Separator()
			end
			if imgui.Button(u8("������������"), imgui.ImVec2(-1, 20)) then
				local ip2, port2 = string.match(v[2], "(.+)%:(%d+)")
				reconname(v[1],ip2, tonumber(port2))
			end
			if imgui.Button(u8("������� ��� ������"), imgui.ImVec2(-1, 20)) then
				savepass[k] = nil
				imgui.CloseCurrentPopup()
				saveaccounts()
			end
			if imgui.Button(u8("�������##sdosodosdosd"), imgui.ImVec2(-1, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.CreatePaddingY(8)
			imgui.EndPopup()
		end
		imgui.NextColumn()
		imgui.Text(tostring(v[2]))
		imgui.NextColumn()
		imgui.Text(u8('���-�� �������: '..#v[3]..'. ������� ��� ��� ���������� ��������'))
		imgui.NextColumn()
	end
	imgui.Columns(1)
	imgui.Separator()
end
--imgui: �������� �����
function autofillelementssave()
	if imgui.Button(u8'< ��������') then menufill = 0 end
	imgui.SameLine()
	imgui.CenterText(u8'��������������')
	imgui.SameLine(838) 
	if imgui.Button(u8('�������')) then temppass = {}; AFKMessage('����� ��������� ������� ������!') end
	imgui.Columns(5, _, true)
	imgui.Separator()--710
	imgui.SetColumnWidth(-1, 130); imgui.Text(u8"������[ID]"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 150); imgui.Text(u8"�������"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 140); imgui.Text(u8"������"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 170); imgui.Text(u8"��������� ������"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 140); imgui.Text(u8"�����"); imgui.NextColumn()
	for k, v in pairs(temppass) do
		if imgui.Selectable('   '..tostring(u8(string.gsub(v.title, "%{.*%}", "") .. "[" .. v.id .. "]")) .. "##" .. k, false, imgui.SelectableFlags.SpanAllColumns) then
			saveacc(k)
			saveaccounts()
			AFKMessage('������ '..v.text..' ��� �������� '..v.nick..' �� ������� '..v.ip..' �������!')
		end
		imgui.NextColumn()
		imgui.Text(tostring(v.nick))
		imgui.NextColumn()
		imgui.Text(tostring(v.ip))
		imgui.NextColumn()
		imgui.Text(tostring(u8(v.text)))
		imgui.NextColumn()
		imgui.Text(tostring(v.time))
		imgui.NextColumn()
	end
	imgui.Columns(1)
	imgui.Separator()
end
function imgui.OnDrawFrame()
	if afksets.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(920,470))
		imgui.SetNextWindowPos(imgui.ImVec2(sw/2,sh/2),imgui.Cond.FirstUseEver,imgui.ImVec2(0.5,0.5))
		-- imgui.PushStyleVar(imgui.StyleVar.WindowPadding,imgui.ImVec2(0,0))
		imgui.Begin('##afktools',afksets,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
		if menunum > 0 then
			imgui.SetCursorPos(imgui.ImVec2(12,8))
			if imgui.Button('<',imgui.ImVec2(20,34)) then
				menunum = 0
			end
		end
		imgui.SetCursorPos(imgui.ImVec2(40,8))
		imgui.RenderLogo() imgui.SameLine() imgui.Text(u8('\n������: bakhusse x mamashin.'))
		imgui.SetCursorPos(imgui.ImVec2(516,8))
		imgui.BeginGroup()
		imgui.Text(u8('������ => �������: '..thisScript().version..' | ����������: '..(updates.data.result and updates.data.relevant_version or 'error')))
		if imgui.Button(u8('��������� ����������'),imgui.ImVec2(150,20)) then
			updates:getlast()
		end
		imgui.SameLine()
		local renderdownloadupd = (updates.data.result and updates.data.relevant_version ~= thisScript().version) and imgui.Button or imgui.ButtonDisabled
		if renderdownloadupd(u8('��������� ����������'),imgui.ImVec2(150,20)) then
			if updates.data.result and updates.data.relevant_version ~= thisScript().version then
				updates:download()
			end
		end
		imgui.EndGroup()
		imgui.SetCursorPos(imgui.ImVec2(880,25))
		imgui.CloseButton(5.5)
		imgui.SetCursorPos(imgui.ImVec2(0,50))
		imgui.Separator()
		if menunum == 0 then
			local buttons = {
				{u8('��������'),1,u8('��������� �������� �������')},
				{u8('��������������'),2,u8('�������� ������ � �������')},
				{u8('VK Notifications'),3,u8('����������� � VK')},
				{u8('�������'),4,u8('������� ����� �� �������')},
				{u8('����������'),5,u8('�������� ���������� � �������')},
				{u8('������� ����������'),6,u8('������ ��������� �������\n	 ��������� � �������')},
				{u8('��������� �������������'),7,u8('����� ��������, ��������� ������.')},
				{u8('����� � ����'),8,u8('���������� ������ ��������� \n                  � ���� � ��')},
			}
			local function renderbutton(i)
				local name,set,desc,func = buttons[i][1],buttons[i][2],buttons[i][3],buttons[i][4]
				local getpos2 = imgui.GetCursorPos()
				imgui.SetCursorPos(getpos2)
				if imgui.Button('##'..name..'//'..desc,imgui.ImVec2(240,80)) then
					if func then
						pcall(func)
					else
						menunum = set
					end
				end 
				imgui.SetCursorPos(getpos2)
				imgui.BeginGroup()
				imgui.CreatePadding(240/2-imgui.CalcTextSize(name).x/2,15)
				imgui.Text(name)
				imgui.CreatePadding(240/2-imgui.CalcTextSize(desc).x/2,(80/2-imgui.CalcTextSize(desc).y/2)-25)
				imgui.Text(desc)
				imgui.EndGroup()
				imgui.SetCursorPos(imgui.ImVec2(getpos2.x,getpos2.y+90))
			end
			imgui.CreatePaddingY(20)
			local cc = 1
			local startY = 120 
			for i = 1, #buttons do
				local poss = {
					80,
					330,
					580
				}
				imgui.SetCursorPos(imgui.ImVec2(poss[cc],startY))
				renderbutton(i)
				if cc == #poss then
					cc = 0
					startY = startY + 90
				end
				cc = cc + 1
			end
			imgui.SetCursorPos(imgui.ImVec2(920/2 - 300/2,400))
			imgui.BeginGroup()
			if imgui.Button(u8('��������� ���������'),imgui.ImVec2(150,30)) then saveini() end
			imgui.SameLine()
			if imgui.Button(u8('������������� ������'),imgui.ImVec2(150,30)) then thisScript():reload() end
			imgui.EndGroup()
			
		elseif menunum == 1 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('�������������'))
			imgui.Separator()
			imgui.Checkbox(u8('�������� �������������'), arec.state)
			if arec.state.v then
				imgui.Checkbox(u8('�������� ������������� ��� You are banned from this server'), arec.statebanned)
			    imgui.SameLine()
			    imgui.PushItemWidth(80)
			    imgui.InputInt(u8('��������(���)###arec'),arec.wait)
			    imgui.PopItemWidth()
			end
			imgui.Separator()
			imgui.CenterText(u8('������������ �������'))
			imgui.Separator()
			imgui.BeginGroup()
			imgui.Checkbox(u8('��������� �������� ������'),roulette.standart); imgui.SameLine() imgui.TextQuestion(u8('��� ����������� ���������� �������� ����������� ������ ������ ���� �� ����� ����� �� 1 ��������')) 
			imgui.Checkbox(u8('��������� ����� ������'),roulette.donate); imgui.SameLine() imgui.TextQuestion(u8('[�����������!] �������� ������ ������ ���� �� ����� ����� �� 1 ��������'))
			imgui.Checkbox(u8('��������� ������� ������'),roulette.platina); imgui.SameLine() imgui.TextQuestion(u8('[�����������!] ���������� ������ ������ ���� �� ����� ����� �� 1 ��������'))
			if imgui.Button(u8('������� ������������ ��������')) then
				downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/open_roulettes.lua',
                   'moonloader\\open_roulettes.lua', 
                   'open_roulettes.lua')
            end
            imgui.SameLine()
			imgui.TextQuestion(u8('����� ���������� ���������� ������������� moonloader ����������� Ctrl+R\n������ ������������� ������������ � ��� ������, ���� ������������ � ������ ������� �������� �����������.\n���������: /boxset'))
			imgui.EndGroup()
			imgui.SameLine(350)
			imgui.BeginGroup()
			imgui.Checkbox(u8('��������� ������ �����'),roulette.mask); imgui.SameLine() imgui.TextQuestion(u8('[�����������!] ������ ����� ������ ���� �� ����� ����� �� 1 ��������'))
			imgui.Checkbox(u8('��������� ������ �������'),roulette.tainik); imgui.SameLine() imgui.TextQuestion(u8('[�����������!] ������ ������� ������ ���� �� ����� ����� �� 1 ��������'))
			imgui.PushItemWidth(100)
			imgui.InputInt(u8('�������� (� �������.)##wait'),roulette.wait)
			imgui.SameLine()
			imgui.TextQuestion(u8('�������� ����� ����� ��������� �������(����� ������� ��� ���)'))
			imgui.PopItemWidth()
			if imgui.Button(u8('��������/��������� ������������ ��������')) then 
			    openchestrullet()
			end
			imgui.EndGroup()
			imgui.Separator()
			imgui.CenterText(u8('������'))
			imgui.Separator()
			imgui.BeginGroup()
			imgui.PushItemWidth(400)
			imgui.InputText(u8('1 ������'),piar.piar1)
			imgui.SameLine()
			imgui.TextQuestion(u8('������������ ������'))
			imgui.InputText(u8('2 ������'),piar.piar2)
			imgui.SameLine()
			imgui.TextQuestion(u8('�������� ������ ������ ���� �� ������ � ������������'))
			imgui.InputText(u8('3 ������'),piar.piar3)
			imgui.SameLine()
			imgui.TextQuestion(u8('�������� ������ ������ ���� �� ������ � ������������'))
			imgui.PopItemWidth()
			imgui.EndGroup()
		
			imgui.SameLine()
		
			imgui.BeginGroup()
			imgui.PushItemWidth(80)
			imgui.InputInt(u8('��������(���.)##piar1'),piar.piarwait); 
			imgui.InputInt(u8('��������(���.)##piar2'),piar.piarwait2); 
			imgui.InputInt(u8('��������(���.)##piar3'),piar.piarwait3); 
			imgui.PopItemWidth()
			imgui.EndGroup()
			if imgui.Button(u8('������������ ������')) then 
			    bizpiaron = not bizpiaron
			    activatePiar(bizpiaron)
			    AFKMessage(bizpiaron and '���� �������!' or '���� ��������!',5)
			end
			imgui.SameLine()
			imgui.Checkbox(u8('��������'),piar.auto_piar) 
			imgui.SameLine()
			imgui.TextQuestion(u8('���� ����� ���������� ���������� ������� ������� ������ ����������(� ����������) �������, ���������� ��������'))
			if piar.auto_piar.v then
			    imgui.SameLine()
			    imgui.PushItemWidth(120)
			    if imgui.InputInt(u8('������������ ����� ��� ��������� �����(� ���.)##autpiar'),piar.auto_piar_kd) then
			        if piar.auto_piar_kd.v < 0 then piar.auto_piar_kd = 0 end
			    end
			    imgui.PopItemWidth()
			end
			imgui.CenterText(u8('��������� ���������'))
			imgui.Separator()
			imgui.BeginGroup()
			if imgui.Checkbox(u8('Fastconnect'),fastconnect) then
				sampFastConnect(fastconnect.v)
			end
			imgui.SameLine()
			imgui.TextQuestion(u8('������� ���� �� ������'))
			if imgui.Checkbox(u8('AntiAFK'),antiafk) then workpaus(antiafk.v) end
			imgui.SameLine()
			imgui.TextQuestion(u8('�� �� ������ ������ � AFK ���� �������� ����\n��������! ���� AntiAFK ������� � �� ��������� ��������� �� ��� ��������� ������ �� ������������� ���������! ������ ���!'))
			if imgui.Button(u8('������� AntiAFK ��� ��������')) then
				downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/AntiAFK_1.4_byAIR.asi',
                getGameDirectory()..'\\AntiAFK_1.4_byAIR.asi',
                'AntiAFK_1.4_byAIR.asi')
				sampAddChatMessage("{FF8000}[AFKTOOLS]{FFFFFF} ����-��� ������� ��������! ����������� ��������� � ����, ����� �� ���������.", -1)
            end
			imgui.Checkbox(u8('AutoScreenBan'),banscreen)
			imgui.SameLine()
			imgui.TextQuestion(u8('���� ��� ������� ����� �� ����� ��������� �������������'))
			imgui.EndGroup()
			imgui.SameLine(350)
			imgui.BeginGroup()
			--imgui.Checkbox(u8('���� ������� /ad'),autoad)
			--imgui.SameLine()
			--imgui.TextQuestion(u8('��� ������������� /ad [�����], ����� ������������� ����� ���� ����������'))
			--imgui.Checkbox(u8('���� ������� /ad ��� ������������'),autoadbiz)
			--imgui.SameLine()
			--imgui.TextQuestion(u8('��� ������������� /ad [�����], ����� ���������� ��� ��� ������������'))
			if imgui.Button(u8('������� VIP-Resend by Cosmo')) then
				downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/vip-resend.lua',
                   'moonloader\\vip-resend.lua', 
                   'vip-resend.lua')
				sampAddChatMessage("{FF8000}[AFKTOOLS]{FFFFFF} VIP-Resend ������� ��������! ������� Ctrl+R ��� ����������� MoonLoader.", -1)
            end
            imgui.SameLine(210)
            imgui.Checkbox(u8('���������'),autologinfix.state)
			imgui.Checkbox(u8('��������������'),autoupdateState)
			imgui.SameLine()
			imgui.TextQuestion(u8('�������� ��������������. �� ��������� ��������'))
			imgui.SameLine(210)
			imgui.BeginGroup()
			if autologinfix.state.v then
				imgui.PushItemWidth(130)
				imgui.InputText(u8('��� ��� �����'), autologinfix.nick)
				imgui.PopItemWidth()
			end
			imgui.EndGroup()
			if imgui.Checkbox(u8'������� ������� � �������', delplayeractive) then
		delplayer = not delplayer
			for _, handle in ipairs(getAllChars()) do
				if doesCharExist(handle) then
					local _, id = sampGetPlayerIdByCharHandle(handle)
					if id ~= myid then
						emul_rpc('onPlayerStreamOut', { id })
						npc[#npc + 1] = id
					end
				end
			end
			
			if not delplayer then
				for i = 1, #npc do
					send_player_stream(npc[i], infnpc[npc[i]])
					npc[i] = nil
				end
			end
		end
	imgui.SameLine()
	imgui.TextQuestion(u8"������� ������� ���� ������� � �������. ����� ������� ��� ����� �.� ������ ���� ����� ����. ����� ������� ������� - ��������� ������� � ������� � ����, ����� ������� �� ��. ��� ����� ������ ��������� � ����.")
			imgui.SameLine(210)
			imgui.BeginGroup()
			if autologinfix.state.v then
				imgui.PushItemWidth(130)
				imgui.InputText(u8('������ ��� �����'), autologinfix.pass, showpass and 0 or imgui.InputTextFlags.Password)
				imgui.PopItemWidth()
				if imgui.Button(u8('��������##1010')) then showpass = not showpass end
			end
			imgui.EndGroup()
			imgui.EndGroup()
			imgui.EndChild()
		elseif menunum == 2 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			if menufill == 0 then
				autofillelementsaccs()
			elseif menufill == 1 then
				autofillelementssave()
			end
			imgui.EndChild()
		elseif menunum == 3 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText('VK Notification')
			imgui.Separator()
			if imgui.Checkbox(u8('�������� �����������'), vknotf.state) then
				if vknotf.state.v then
					longpollGetKey()
				end
			end
			if vknotf.state.v then
				imgui.BeginGroup()
				if vkerr then
					imgui.Text(u8'��������� �����: ' .. u8(vkerr))
					imgui.Text(u8'��� ��������������� � �������� ������� ������ "���������������� � ��������"')
				else
					imgui.Text(u8'��������� �����: �������!') --
				end
				if vkerrsend then
					imgui.Text(u8'��������� ��������: ' .. u8(vkerrsend))
				else
					imgui.Text(u8'��������� ��������: �������!')
				end
				imgui.InputText(u8('�����'), vknotf.token, showtoken and 0 or imgui.InputTextFlags.Password)
				imgui.SameLine()
				if imgui.Button(u8('��������##1010')) then showtoken = not showtoken end
				imgui.InputText(u8('VK ID ������'), vknotf.group_id)
				imgui.SameLine()
				imgui.TextQuestion(u8('� ������!'))
				imgui.InputText(u8('VK ID'), vknotf.user_id)
				imgui.SameLine()
				imgui.TextQuestion(u8('� ������!'))
				imgui.SetNextWindowSize(imgui.ImVec2(900,530)) -- � �������� (600,230) � ��� (900,530)
				if imgui.BeginPopupModal('##howsetVK',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
					imgui.Text(u8(howsetVK))
					imgui.SetCursorPosY(490) -- � �������� (200) � ��� (490)
					local wid = imgui.GetWindowWidth()
					imgui.SetCursorPosX(wid / 2 - 30)
					if imgui.Button(u8'�������', imgui.ImVec2(60,20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
				if imgui.Button(u8('��� ���������')) then imgui.OpenPopup('##howsetVK') end
				imgui.SameLine()
				imgui.SetNextWindowSize(imgui.ImVec2(600,200))
                if imgui.BeginPopupModal('##howscreen',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
					imgui.Text(u8(howscreen))
					imgui.SetCursorPosY(150)
					local wid = imgui.GetWindowWidth()
					imgui.SetCursorPosX(wid / 2 - 30)
					if imgui.Button(u8'�������', imgui.ImVec2(60,20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
                if imgui.Button(u8('��� ��������� !screen')) then imgui.OpenPopup('##howscreen') end
				if imgui.Button(u8('��������� �����������')) then sendvknotf('������ ��������!') end
				imgui.SameLine()
				if imgui.Button(u8('���������������� � ��������')) then longpollGetKey() end
				if imgui.Button(u8('������� ������ ����������')) then
					downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/dkjson.lua',
                    'moonloader\\lib\\dkjson.lua', 
                    'dkjson.lua')
					downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/effil.lua',
                    'moonloader\\lib\\effil.lua', 
                    'effil.lua')
					downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/multipart-post.lua',
                    'moonloader\\lib\\multipart-post.lua', 
                    'multipart-post.lua')
					downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/requests.lua',
                    'moonloader\\lib\\requests.lua', 
                    'requests.lua')
					AFKMessage('���������� ������� ���������!')
                end
                imgui.SameLine()
                if imgui.Button(u8('������� ������ � ��������')) then
					downloadUrlToFile('https://raw.githubusercontent.com/JekSkeez/afktools/main/afktools_p.lua',
                    'moonloader\\afktools.lua', 
                    'afktools.lua')
					AFKMessage('����������...')
                end
				imgui.EndGroup()
				imgui.Separator()
				imgui.CenterText(u8('�������, ��� ������� ����������� �����������'))
				imgui.Separator()
				imgui.BeginGroup()
				imgui.Checkbox(u8('�����������'),vknotf.isinitgame); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� ����������� � �������'))
				imgui.Checkbox(u8('�������������'),vknotf.isadm); imgui.SameLine(); imgui.TextQuestion(u8('���� � ������ ����� ����� "�������������" + ��� ��� + ������� ������(����.: ���� /pm, ��� /pm, ban ���� ����� �����������)'))
				imgui.Checkbox(u8('�����'),vknotf.ishungry); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� �������������'))
				imgui.Checkbox(u8('���'),vknotf.iscloseconnect); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� ���������� �� �������'))
				imgui.Checkbox(u8('��������'),vknotf.isdemorgan); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� ������ �� ���������'))
				imgui.Checkbox(u8('SMS � ������'),vknotf.issmscall); imgui.SameLine(); imgui.TextQuestion(u8('���� ��������� ������ ��� ��� ��������'))
				imgui.Checkbox(u8('������ �������'),vknotf.record); imgui.SameLine(); imgui.TextQuestion(u8('������ ������, ������������ � ��. �������� � ��������������'))
				imgui.Checkbox(u8('�������� � ��������� ��������'),vknotf.bank); imgui.SameLine(); imgui.TextQuestion(u8('��� ��������� ��� ����������� �������� ������ �����������'))
				imgui.EndGroup()
				imgui.SameLine(350)
				imgui.BeginGroup()
				imgui.Checkbox(u8('PayDay'),vknotf.ispayday); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� ������� PayDay'))
				imgui.Checkbox(u8('������'),vknotf.islowhp); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� �����(���� ��� ���-�� �����, ������� ��� ���)'))
				imgui.Checkbox(u8('���� �������'),vknotf.iscrashscript); imgui.SameLine(); imgui.TextQuestion(u8('���� ������ ����������/���������(���� ���� ������������� ����� CTRL + R)'))
				imgui.Checkbox(u8('�������'),vknotf.issellitem); imgui.SameLine(); imgui.TextQuestion(u8('���� �������� ������� ���-�� �� �� ��� ��'))
				imgui.Checkbox(u8('�� �����/�������'),vknotf.ismeat); imgui.SameLine(); imgui.TextQuestion(u8('���� �� �� �����/������ �� ������, ��� ���� ������� ������� �� ������ �����������'))
				imgui.Checkbox(u8('��� � �����/��'),vknotf.iscode); imgui.SameLine(); imgui.TextQuestion(u8('���� ����� ����������� ��� � �����/��, �� ������ �����������'))
				imgui.Checkbox(u8('�������� ���� ��������'),vknotf.dienable); imgui.SameLine(); imgui.TextQuestion(u8('������ ���������� ��� ��������� ������� �� ���� /mm, /stats � ���� ������ � VK.'))
				imgui.EndGroup()
			end
			imgui.EndChild()
		elseif menunum == 4 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('�������'))
			imgui.Separator()
			imgui.BeginGroup()
        	imgui.RadioButton(u8'�������',eat.eatmetod,0)
			if eat.eatmetod.v > 0 then
				imgui.SameLine()
				imgui.PushItemWidth(140)
				imgui.Combo(u8('������ �������� ������'), eat.checkmethod, checklist, -1)
				if eat.checkmethod.v == 1 then
					imgui.PushItemWidth(80)
					imgui.SameLine()
					imgui.InputInt(u8('��� ������� ��������� ������ ���� ������'),eat.eat2met,0)
				end
				imgui.PopItemWidth()
			end
			imgui.RadioButton(u8'������ ����',eat.eatmetod,1)
        	imgui.SameLine()
        	imgui.TextQuestion(u8'��� �������� ����� ������ ���� �� ������������')
        	imgui.BeginGroup()
        	imgui.RadioButton(u8'������ ��� ����',eat.eatmetod,2)
        	imgui.SameLine()
        	imgui.TextQuestion(u8'��� �������� ����� ������ ��� ���� �������� �� ������')
        	if eat.eatmetod.v == 2 then
        	    imgui.Text(u8'����� ������ ���:')
        	    imgui.PushItemWidth(100)
        	    imgui.Combo('##123123131231232', eat.setmetod, metod, -1)
        	    if eat.setmetod.v == 3 then
        	        imgui.Text(u8("ID TextDraw'a ���"))
        	        imgui.InputInt(u8"##eat", eat.arztextdrawid,0)      
        	    end    
        	    imgui.PopItemWidth()
        	end
        	imgui.EndGroup()
        	imgui.RadioButton(u8'������ � ��� ��',eat.eatmetod,3)
        	imgui.SameLine()
        	imgui.TextQuestion(u8'��� �������� ����� ������ �� ������������ � �������� ��������. ��� ������������� �������� �� �����, ��� ��� ������� ALT �������� ������ � ������� ���')
        	imgui.EndGroup()
        	imgui.BeginGroup()
        	imgui.Checkbox(u8'�������', eat.healstate)
        	-- imgui.SameLine()
        	if eat.healstate.v then
        	    imgui.PushItemWidth(40)
        	    imgui.InputInt(u8'������� HP ��� ����', eat.hplvl,0)
        	    imgui.PopItemWidth()
        	    imgui.Text(u8 '����� ������ ����:')
        	    imgui.PushItemWidth(100)
				imgui.Combo('##ban',eat.hpmetod,healmetod,-1)
				if eat.hpmetod.v == 1 then
        	        imgui.PushItemWidth(30)
        	        imgui.InputInt(u8"���-�� �����",eat.drugsquen,0)
        	        imgui.PopItemWidth()
        	    end
        	    if eat.hpmetod.v == 4 then
        	        imgui.Text(u8("ID TextDraw'a ����"))
        	        imgui.InputInt(u8"##heal",eat.arztextdrawidheal,0)
        	    end
        	    imgui.PopItemWidth()
        	end
        	imgui.EndGroup()
        	imgui.SameLine(130)
        	if imgui.Checkbox(u8('�������� ����������� ID �����������'), imgui.ImBool(idsshow)) then
        	    idsshow = not idsshow
        	end
			imgui.EndChild()
		elseif menunum == 5 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('����������'))
			imgui.Separator()
			imgui.Text(u8(scriptinfo))
			if imgui.Button(u8('������ VK')) then
				os.execute("start https://vk.com/notify.arizona")
			end
			imgui.SameLine()
			if imgui.Button(u8('Telegram-�����')) then
				os.execute("start https://t.me/bakhusse_channel")
			end
			if imgui.Button(u8('VK ������������')) then
				os.execute("start https://vk.com/sk33z")
			end
			imgui.EndChild()
		elseif menunum == 6 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('������� ����������'))
			imgui.Separator()
			imgui.Text(u8(changelog))
			imgui.Text(u8(changelog2))
			imgui.Text(u8(changelog3))
			imgui.Text(u8(changelog4))
			imgui.EndChild()
		elseif menunum == 7 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('��������� �������������'))
			imgui.Separator()
        	imgui.Checkbox(u8('������������'),autoo)
        	imgui.InputText(u8('����� �������������'),atext)
			imgui.Combo(u8('�������'), aphone, aomethod, -1)
			imgui.EndChild()
		elseif menunum == 8 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('��������� �������� ������ �� ������ � ���� � VK'))
			imgui.Separator()
			imgui.Text('')
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'���������� ��������� ����� � VK', find.vkfind) imgui.SameLine() imgui.TextQuestion(u8"���� ��������, �� ��� � VK ����� ��������� �����, ������� �� �����. �������� ��� �� ��������: ��������� ������ ���������� ��������� ����� � ������� ��� ������ � ������ ������� �������� ������ ����� (��������, �� ������ ������ ���������� ������������ �����. ������ � ��������� ����, ��������, 'BMW M6' � ���� � ���� ��� �� ������� ������ ������ �������� ����������, �� ��� ������ ������ ����� �� ���� � VK. ����� ��������� ��������� ���������. ���� ��� ������ �� �����, ����� ������� ����� �������� � VK, ������ ������� �������� ��������� ���� �������. ���������� ������� ��������� ����� ���� �������.")
			imgui.Text('')
			imgui.PushItemWidth(350)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������', find.vkfindtext) imgui.SameLine() imgui.InputText(u8'##�������1', find.inputfindvk)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������2', find.vkfindtext6) imgui.SameLine() imgui.InputText(u8'##�������6', find.inputfindvk6)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������3', find.vkfindtext2) imgui.SameLine() imgui.InputText(u8'##�������2', find.inputfindvk2)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������4', find.vkfindtext7) imgui.SameLine() imgui.InputText(u8'##�������7', find.inputfindvk7)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������5', find.vkfindtext3) imgui.SameLine() imgui.InputText(u8'##�������3', find.inputfindvk3)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������6', find.vkfindtext8) imgui.SameLine() imgui.InputText(u8'##�������8', find.inputfindvk8)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������7', find.vkfindtext4) imgui.SameLine() imgui.InputText(u8'##�������4', find.inputfindvk4)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������8', find.vkfindtext9) imgui.SameLine() imgui.InputText(u8'##�������9', find.inputfindvk9)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������9', find.vkfindtext5) imgui.SameLine() imgui.InputText(u8'##�������5', find.inputfindvk5)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##������������������10', find.vkfindtext10) imgui.SameLine() imgui.InputText(u8'##�������10', find.inputfindvk10)
			imgui.PopItemWidth()
			imgui.EndChild()
		end
		imgui.End()
	end
	onRenderNotification()
end
function imgui.ButtonDisabled(...)

    local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
    imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])

        local result = imgui.Button(...)

    imgui.PopStyleColor()
    imgui.PopStyleColor()
    imgui.PopStyleColor()
    imgui.PopStyleColor()

    return result
end
function imgui.CloseButton(rad)
	local pos = imgui.GetCursorScreenPos()
	local poss = imgui.GetCursorPos()
	local a,b,c,d = pos.x - rad, pos.x + rad, pos.y - rad, pos.y + rad
	local e,f = poss.x - rad, poss.y - rad
	local list = imgui.GetWindowDrawList()
	list:AddLine(imgui.ImVec2(a,d),imgui.ImVec2(b,c),convertImVec4ToU32(convertHexToImVec4('FFFFFF')))
	list:AddLine(imgui.ImVec2(b,d),imgui.ImVec2(a,c),convertImVec4ToU32(convertHexToImVec4('FFFFFF')))
	imgui.SetCursorPos(imgui.ImVec2(e,f))
	if imgui.InvisibleButton('##closebutolo',imgui.ImVec2(rad*2,rad*2)) then
		afksets.v = false
	end
end
function imgui.RenderLogo()
	imgui.Image(logos,imgui.ImVec2(40,40))
end
function imgui.CenterText(text) 
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.TextQuestion(text)
  imgui.TextDisabled('(?)')
  imgui._atq(text)
end
function imgui._atq(text)
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end
function imgui.CreatePaddingX(x)
	x = x or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPosX(cc.x+x)
end
function imgui.CreatePaddingY(y)
	y = y or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPosY(cc.y+y)
end
function imgui.CreatePadding(x,y)
	x,y = x or 8, y or 8
	local cc = imgui.GetCursorPos()
	imgui.SetCursorPos(imgui.ImVec2(cc.x+x,cc.y+y))
end


function onScriptTerminate(scr,qgame)
	if scr == thisScript() then
		mainIni.piar.last_time = os.time()
		local saved = inicfg.save(mainIni,'afktools.ini')
		if vknotf.iscrashscript.v then
			sendvknotf('������ ���� :(')
		end	
	end
end
--�������� ��� ����������
function sampGetAllTextDraws()
	local tds = {}
	pTd = sampGetTextdrawPoolPtr() + 9216
	for i = 0,2303 do
		if readMemory(pTd + i*4,4) ~= 0 then
			table.insert(tds,i)
		end
	end
	return tds
end

--������� �����
function takeScreen()
	if isSampLoaded() then
		memory.setuint8(sampGetBase() + 0x119CBC, 1)
	end
end
--antiafk
function workpaus(bool)	
	if bool then
		memory.setuint8(7634870, 1, false)
		memory.setuint8(7635034, 1, false)
		memory.fill(7623723, 144, 8, false)
		memory.fill(5499528, 144, 6, false)
	else
		memory.setuint8(7634870, 0, false)
		memory.setuint8(7635034, 0, false)
		memory.hex2bin('0F 84 7B 01 00 00', 7623723, 8)
		memory.hex2bin('50 51 FF 15 00 83 85 00', 5499528, 6)
	end
	-- AFKMessage('AntiAFK '..(bool and '��������' or '�� ��������'))
end
function sampFastConnect(bool)
	if bool then 
		writeMemory(sampGetBase() + 0x2D3C45, 2, 0, true)
	else
		writeMemory(sampGetBase() + 0x2D3C45, 2, 8228, true)
	end
end
-- ��������������
function findDialog(id, dialog)
	for k, v in pairs(savepass[id][3]) do
		if v.id == dialog then
			return k
		end
	end
	return -1
end
function findAcc(nick, ip)
	for k, v in pairs(savepass) do
		if nick == v[1] and ip == v[2] then
			return k
		end
	end
	return -1
end
function getAcc()
	local nick = tostring(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
	local ip, port = sampGetCurrentServerAddress()
	local ip = ip .. ":" .. port
	local acc = findAcc(nick, ip)
	return acc
end

--����������������������
function onReceivePacket(id, bitStream)
	if (id == PACKET_DISCONNECTION_NOTIFICATION or id == PACKET_INVALID_PASSWORD) then
		goaurc()
	end
	if (id == PACKET_CONNECTION_BANNED) then	
		ip,port = sampGetCurrentServerAddress()
		if arec.state.v and arec.statebanned.v then
			lua_thread.create(function()
				wait(1000)
				sampConnectToServer(ip,port)
			end)
		end
	end
	if autologinfix.state.v then
		if(id == 220) then
		raknetBitStreamIgnoreBits(bitStream, 8)
		if(raknetBitStreamReadInt8(bitStream) == 17) then
			raknetBitStreamIgnoreBits(bitStream, 32)
			if(raknetBitStreamReadString(bitStream, raknetBitStreamReadInt32(bitStream)):match("window%.executeEvent%('event%.setActiveView', '%[\"Auth\"%]'%);")) then
				lua_thread.create(function()
				wait(200)
local NICK = mainIni.autologinfix.nick
local PASS = mainIni.autologinfix.pass
local BITSTREAM = raknetNewBitStream()
raknetBitStreamWriteInt8(BITSTREAM, 220)
raknetBitStreamWriteInt8(BITSTREAM, 18)
raknetBitStreamWriteInt8(BITSTREAM, string.len(string.format("authorization|%s|%s|0", NICK, PASS)))
raknetBitStreamWriteInt8(BITSTREAM, 0)
raknetBitStreamWriteInt8(BITSTREAM, 0)
raknetBitStreamWriteInt8(BITSTREAM, 0)
raknetBitStreamWriteString(BITSTREAM, string.format("authorization|%s|%s|0", NICK, PASS))
raknetBitStreamWriteInt32(BITSTREAM, 1)
raknetBitStreamWriteInt8(BITSTREAM, 0)
raknetBitStreamWriteInt8(BITSTREAM, 0)
raknetSendBitStreamEx(BITSTREAM, 1, 7, 1)
raknetDeleteBitStream(BITSTREAM)
					end)
				end
			end
		end
	end
end
function onReceiveRpc(id,bitStream)
	if (id == RPC_CONNECTIONREJECTED) then
		goaurc()
	end
end

tblclosetest = {['50.83'] = 50.84, ['49.9'] = 50, ['49.05'] = 49.15, ['48.2'] = 48.4, ['47.4'] = 47.6, ['46.5'] = 46.7, ['45.81'] = '45.84',
['44.99'] = '45.01', ['44.09'] = '44.17', ['43.2'] = '43.4', ['42.49'] = '42.51', ['41.59'] = '41.7', ['40.7'] = '40.9', ['39.99'] = 40.01,
['39.09'] = 39.2, ['38.3'] = 38.4, ['37.49'] = '37.51', ['36.5'] = '36.7', ['35.7'] = '35.9', ['34.99'] = '35.01', ['34.1'] = '34.2';}
tblclose = {}

sendcloseinventory = function()
	sampSendClickTextdraw(tblclose[1])
end
function sampev.onShowTextDraw(id,data)
	-- for k,v in pairs(data) do
	-- 	if id == 2110 then
	-- 		__idclosebutton = id
	-- 		print(k,v)
	-- 		if type(v) == 'table' then
	-- 			for kb,bv in pairs(v) do
	-- 				print('	',kb,bv)
	-- 			end
	-- 		end
	-- 	end
	-- end

	--find close button / thx dmitriyewich
	for w, q in pairs(tblclosetest) do
		if data.lineWidth >= tonumber(w) and data.lineWidth <= tonumber(q) and data.text:find('^LD_SPAC:white$') then
			for i=0, 2 do rawset(tblclose, #tblclose + 1, id) end
		end
	end

	if eat.checkmethod.v == 1 then
		if data.boxColor == -1436898180 then 
			if data.position.x == 549.5 and data.position.y == 60 then
				print('get hun > its hungry')
				if math.floor(((data.lineWidth - 549.5) / 54.5) * 100) <= eat.eat2met.v then
					onPlayerHungry:run()
				end
			end
		end
	end
	if aopen then -- state
	 lua_thread.create(function()
		if roulette.standart.v then --standard
			if data.modelId == 19918 then --standart model
				opentimerid.standart = id + 1
			end
			if checkopen.standart then
				if id == opentimerid.standart then
					AFKMessage('[standart] ������� ������� ������')
					wait(500)
					sampSendClickTextdraw(id - 1)
					use = true
					wait(500)
					if use then
      					sampSendClickTextdraw(2302)
        				use = false
      				end
					if not checkopen.donate and not checkopen.platina and not checkopen.mask and not checkopen.tainik then
						sendcloseinventory()
					end
					checkopen.standart = false
				end
			end
		end
		wait(1000)
		if roulette.donate.v then
			if data.modelId == 19613 then --standart model
				opentimerid.donate = id + 1
			end
			if checkopen.donate then
				if id == opentimerid.donate then
					AFKMessage('[donate] ������� ������� ������')
					wait(500)
					sampSendClickTextdraw(id - 1)
					use = true
					wait(500)
					if use then
      					sampSendClickTextdraw(2302)
        				use = false
      				end
					if not checkopen.standart and not checkopen.platina and not checkopen.mask and not checkopen.tainik then
						sendcloseinventory()
					end
					checkopen.donate = false
				end
			end
		end
		wait(1000)
		if roulette.platina.v then
			if data.modelId == 1353 then --standart model
				opentimerid.platina = id + 1
			end
			if checkopen.platina then
				if id == opentimerid.platina then
					AFKMessage('[platina] ������ ������� ������')
					wait(500)
					sampSendClickTextdraw(id - 1)
					use = true
					wait(500)
					if use then
      					sampSendClickTextdraw(2302)
        				use = false
      				end
					if not checkopen.standart and not checkopen.donate and not checkopen.mask and not checkopen.tainik then
						sendcloseinventory()
					end
					checkopen.platina = false
				end
			end
		end
		wait(1000)
		if roulette.mask.v then
			if data.modelId == 1733 then --standart model
				opentimerid.mask = id + 1
			end
			if checkopen.mask then
				if id == opentimerid.mask then
					AFKMessage('[mask] ������ ������� ������')
					wait(500)
					sampSendClickTextdraw(id - 1)
					use = true
					wait(500)
					if use then
      					sampSendClickTextdraw(2302)
        				use = false
      				end
					if not checkopen.standart and not checkopen.donate and not checkopen.platina and not checkopen.tainik then
						sendcloseinventory()
					end
					checkopen.mask = false
				end
			end
		end
		wait(1000)
		if roulette.tainik.v then
			if data.modelId == 2887 then --standart model
				opentimerid.tainik = id + 1
			end
			if checkopen.tainik then
				if id == opentimerid.tainik then
					AFKMessage('[tainik] ������ ������� ������')
					wait(500)
					sampSendClickTextdraw(id - 1)
					use = true
					wait(500)
					if use then
      					sampSendClickTextdraw(2302)
        				use = false
      				end
					if not checkopen.standart and not checkopen.donate and not checkopen.platina and not checkopen.mask then
						sendcloseinventory()
					end
					checkopen.tainik = false
				end
			end
		end
	 end)
	end
	--print('ID = %s, ModelID = %s, text = %s',id,data.modelId, data.text)
end
function sampev.onSetPlayerHealth(healthfloat)
	if eat.healstate.v and sampIsLocalPlayerSpawned() then
		if healthfloat <= eat.hplvl.v then
			if eat.hpmetod.v == 0 then
				sampSendChat('/usemed')
			elseif eat.hpmetod.v == 1 then
				sampSendChat('/usedrugs '..eat.drugsquen.v)
			elseif eat.hpmetod.v == 2 then
				sampSendChat('/adrenaline')
			elseif eat.hpmetod.v == 3 then
				sampSendChat('/beer')
			elseif eat.hpmetod.v == 4 then
				sampSendClickTextdraw(eat.arztextdrawidheal.v)
			elseif eat.hpmetod.v == 5 then
				sampSendChat('/smoke')
			end 
		end   
	end
end
function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
	local killer = ''
	if vknotf.islowhp.v then
		if sampGetPlayerHealth(select(2, sampGetPlayerIdByCharHandle(playerPed))) - damage <= 0 and sampIsLocalPlayerSpawned() then
			if playerId > -1 and playerId < 1001 then
				killer = '\n������: '..sampGetPlayerNickname(playerId)..'['..playerId..']'
			end
			sendvknotf('��� �������� ����'..killer)
		end
	end
end
function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
	if dialogText:find('�� �������� ��� ��������') then
		if banscreen.v then
			createscreen:run()
		end
		if vknotf.isadm.v then
			local svk = dialogText:gsub('\n','') 
			svk = svk:gsub('\t','') 
			sendvknotf('(warning | dialog) '..svk)
		end
	end
	if fix and dialogText:find("���� ���������� �����") then
		sampSendDialogResponse(dialogId, 0, 0, "")
		sampAddChatMessage("{ffffff} inventory {ff0000}fixed{ffffff}!",-1)   
		return false
	end
	if dialogId == 15346 then
		if autoad.v then
			sampSendDialogResponse(15346, 1, 0, -1)
		end
	end
	if dialogId == 25473 then
		if autoad.v then
			sampSendDialogResponse(25473, 1, 0, -1)
		end
	end
	if dialogId == 25473 then
		if autoadbiz.v then
			sampSendDialogResponse(25473, 1, 0, -1)
		end
	end
	if dialogId == 15347 then
		if autoad.v then
			sampSendDialogResponse(15347, 1, 0, -1)
		end
	end
	if dialogId == 15379 then
		if autoad.v then
			sampSendDialogResponse(15379, 0, 0, -1)
		end
	end
	if dialogId == 15346 then
		if autoadbiz.v then
			sampSendDialogResponse(15346, 1, 2, -1)
		end
	end
	if dialogId == 15347 then
		if autoadbiz.v then
			sampSendDialogResponse(15347, 1, 0, -1)
		end
	end
	if dialogId == 15379 then
		if autoadbiz.v then
			sampSendDialogResponse(15379, 0, 0, -1)
		end
	end
	if vknotf.dienable.v then
		if dialogStyle == 1 or dialogStyle == 3 then
			sendvknotf('' .. dialogTitle .. '\n' .. dialogText .. '\n\n[______________]\n\n[' .. okButtonText .. '] | [' .. cancelButtonText .. ']' )
		else
			if dialogStyle == 0 then
				dialogkey()
				senddialog2('' .. dialogTitle .. '\n' .. dialogText .. '\n\n[' .. okButtonText .. '] | [' .. cancelButtonText .. ']' )
			else
				sendvknotf('' .. dialogTitle .. '\n' .. dialogText .. '\n\n[' .. okButtonText .. '] | [' .. cancelButtonText .. ']' )
			end
        end
    end
	if vknotf.isadm.v then
		if dialogText:find('������������� (.+) ������� ���') then
			local svk = dialogText:gsub('\n','') 
			svk = svk:gsub('\t','') 
			sendvknotf('(warning | dialog) '..svk)
		end
	end
	if vknotf.iscode.v and dialogText:find('���� ����������') then sendvknotf('��������� ��� � �����.\n������ ���: !sendcode ���') end
	if vknotf.iscode.v and dialogText:find('����� ������ ��������� ��� �� ��������') then sendvknotf('��������� ��� � ��.\n������ ���: !sendvk ���') end
	if vknotf.iscode.v and dialogText:find('� ����� �������� ���������� ����������') then sendvknotf('��������� ��� �� GAuthenticator.\n������ ���: !gauth ���') end
	if gotoeatinhouse then
		local linelist = 0
		for n in dialogText:gmatch('[^\r\n]+') do
			if dialogId == 174 and n:find('���� ����') then
				print('debug: 174 dialog')
				sampSendDialogResponse(174, 1, linelist, false)
			elseif dialogId == 2431 and n:find('�����������') then
				print('debug: 2431 dialog')
				sampSendDialogResponse(2431, 1, linelist, false)
			elseif dialogId == 185 and n:find('����������� ����') then
				print('debug: 185 dialog')
				sampSendDialogResponse(185, 1, linelist-1, false)
				gotoeatinhouse = false
			end
			linelist = linelist + 1
		end
		return false
	end
	if gethunstate and dialogId == 0 and dialogText:find('���� �������') then
		sampSendDialogResponse(id,0,0,'')
		gethunstate = dialogText
		return false
	end
	if sendstatsstate and dialogId == 235 then
		sampSendDialogResponse(id,0,0,'')
		sendstatsstate = dialogText
		return false
	end
	if dialogStyle == 1 or dialogStyle == 3 then
		local acc = getAcc()
		local bool = true
		if acc > -1 then
			if autologin.state.v then
				local dialog = findDialog(acc, dialogId)
				if dialog > -1 then
				
					sampSendDialogResponse(dialogId, 1, 0, tostring(savepass[acc][3][dialog].text))
					return false
				else
					bool = true
				end
			end
		else
			bool = true
		end
		if bool then
			dialogChecker.check = true
			dialogChecker.id = dialogId
			dialogChecker.title = dialogTitle
		end
	else
		dialogChecker.check = false
		dialogChecker.id = -1
		dialogChecker.title = ""
	end
end
function sampev.onServerMessage(color,text)
	-- print(text .. ' \\ ' .. color)
	if gotoeatinhouse then
		if text:find('��������������') then
			AFKMessage('���������� ��������! �������� ���������!')
			gotoeatinhouse = false
		end
	end
	if vknotf.issellitem.v then 
		if color == -1347440641 and text:find('�� �������') and text:find('��������') then
			sendvknotf(text)
		end
		if color == 1941201407 and text:find('����������� � �������� ������������� ��������') then
			sendvknotf('����������� � �������� ������������� ��������')
		end
	end
	if color == -10270721 and text:find('�� ������ ����� �� ��������������� ��������') then
		if vknotf.isdemorgan.v then
			sendvknotf(text)
		end
	end
	if text:find('^������������� (.+) ������� ���') then
		if vknotf.isadm.v then
			sendvknotf('(warning | chat) '..text)
		end
	end
	if color == -10270721 and text:find('�������������') then
		local res, mid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		if res then 
			local mname = sampGetPlayerNickname(mid)
			if text:find(mname) then
				if vknotf.isadm.v then
					sendvknotf(text)
				end
			end
		end
	end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext.v and text:find(''..u8:decode(find.inputfindvk.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext2.v and text:find(''..u8:decode(find.inputfindvk2.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext3.v and text:find(''..u8:decode(find.inputfindvk3.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext4.v and text:find(''..u8:decode(find.inputfindvk4.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext5.v and text:find(''..u8:decode(find.inputfindvk5.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext6.v and text:find(''..u8:decode(find.inputfindvk6.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext7.v and text:find(''..u8:decode(find.inputfindvk7.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext8.v and text:find(''..u8:decode(find.inputfindvk8.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext9.v and text:find(''..u8:decode(find.inputfindvk9.v)) then sendvknotf('�� ������ �������: '..text) end
	if vknotf.state.v and find.vkfind.v and find.vkfindtext10.v and text:find(''..u8:decode(find.inputfindvk10.v)) then sendvknotf('�� ������ �������: '..text) end

	if vknotf.issmscall.v and text:find('��� ������ ����� ���������!') then sendvknotf('��� �������� ���!') end
	if text:find('�������(�) �������� � ��������(�) ������') and healthfloat <= eat.hplvl.v then sampSendChat('/smoke') end
	if text:find('��������� �������� %(��������%)') then sampSendChat('/smoke') end
	if vknotf.bank.v and text:match("�� ��������") then sendvknotf(text) end
	if vknotf.bank.v and text:match("��� �������� ������� �� ��� ���� � �������") then sendvknotf(text) end
	if autoo.v and text:find('�� ������� ������') then sampSendChat(u8:decode(atext.v)) end
	if vknotf.iscode.v and text:find('�� ������� ���� ���������, ����������� ������� Y ��� ������ � ���.') then sendvknotf('�������� ���������') end
	if vknotf.ismeat.v and (text:find('������������ ����� � ����� ����� ��� � 30 �����!') or text:find('����� ����� �������� ������������� ��� �� ������!') or text:find('������ � ��������� � ��������')) then sendvknotf(text) end
	if vknotf.record.v and (text:find('%[���%]%:') or text:find('�� ������� ������') or text:find('�� �������� ������') or text:find('������ �������! ����� ���������')) then sendvknotf(text) end
	if autoo.v and text:find('��� ����, ����� �������� ������ ���������� ��� ') then
		PickUpPhone()
		if vknotf.issmscall.v then 
			sendphonecall()
		end
	end
	if vknotf.ispayday.v then
		if text:find('���������� ���') and color == 1941201407 then
			vknotf.ispaydaystate = true
			vknotf.ispaydaytext = ''
		end
		if vknotf.ispaydaystate then
			if text:find('������� � �����') then 
				vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
			elseif text:find('����� � �������') then
				vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text 
			elseif text:find('������� ����� � �����') then
				vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
			elseif text:find('������� ����� �� ��������') then
				vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
			elseif text:find('� ������ ������ � ���') then
				vknotf.ispaydaytext = vknotf.ispaydaytext..'\n'..text
				sendvknotf(vknotf.ispaydaytext)
				vknotf.ispaydaystate = false
				vknotf.ispaydaytext = ''
			end
		end
	end
end
function sampev.onInitGame(playerId, hostName, settings, vehicleModels, unknown)
	if vknotf.isinitgame.v then
		sendvknotf('�� ������������ � �������!', hostName)
	end
end
function sampev.onDisplayGameText(style, time, text)
	-- print('[GameText | '..os.date('%H:%M:%S')..'] '..'style == '..style..', time == '..time..', text == '..text)
	if eat.checkmethod.v == 0 then
		if text == ('You are hungry!') or text == ('~r~You are very hungry!') then
			if vknotf.ishungry.v then
				sendvknotf('�� �������������!')
			end
			onPlayerHungry:run()
		end
	end
end
function sampev.onSendDialogResponse(dialogid, button, list, text)
	if dialogChecker.check and dialogChecker.id == dialogid and button == 1 then
		local ip, port = sampGetCurrentServerAddress()
		table.insert(temppass, {
			id = dialogid,
			title = dialogChecker.title,
			text = text,
			time = os.date("%H:%M:%S"),
			ip = ip .. ":" .. port,
			nick = tostring(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
		})
		dialogChecker.check = false
		dialogChecker.id = -1
		dialogChecker.title = ""
	end
end	
-- ������ 
-- ����� �������� 
function reconstandart(timewait,bool_close)
	if handle_aurc then
		handle_aurc:terminate()
		handle_aurc = nil
		AFKMessage('������������� ���������� �.� �� ������������ ������� ���������')
	end
	if handle_rc then
		handle_rc:terminate()
		handle_rc = nil
		AFKMessage('���������� ��������� ��� ����������')
	end
	handle_rc = lua_thread.create(function(timewait2, bclose)
		bclose = bclose or true
		if bclose then
			closeConnect()
		end
		timewait2 = tonumber(timewait2)
		if timewait2 then	
			if timewait2 >= 0 then
				recwaitim = timewait2*1000
				AFKMessage('��������� ����� '..timewait2..' ������')
				wait(recwaitim)
				sampConnectToServer(sampGetCurrentServerAddress())
			end
		else
			AFKMessage('���������...')
			sampConnectToServer(sampGetCurrentServerAddress())
		end  
		handle_rc = nil
	end,timewait, bool_close)
end
--����� � ����� 
function reconname(playername,ips,ports)
	if handle_aurc then
		handle_aurc:terminate()
		handle_aurc = nil
		AFKMessage('������������� ���������� �.� �� ������������ ��������� � �����')
	end
	if handle_rc then
		handle_rc:terminate()
		handle_rc = nil
		AFKMessage('���������� ��������� ��� ����������')
	end
	handle_rc = lua_thread.create(function()
		if #playername == 0 then
			AFKMessage('������� ��� ��� ����������')
		else
			closeConnect()
			sampSetLocalPlayerName(playername)
			AFKMessage('��������� � ����� �����\n'..playername)
			local ip, port = sampGetCurrentServerAddress()
			ips,ports = ips or ip, ports or port
			sampConnectToServer(ips,ports)
		end 
	end)
end
-- ������� autorecon
function goaurc()
	if vknotf.iscloseconnect.v then
		sendvknotf('�������� ���������� � ��������')
	end
	if arec.state.v then
		if handle_aurc then
			handle_aurc:terminate()
			handle_aurc = nil
			AFKMessage('���������� ������������� ��� ����������')
		end
		if handle_rc then
			handle_rc:terminate()
			handle_rc = nil
			AFKMessage('������� ������������� ��� ���������� �.� �������� �������������')
		end
		handle_aurc = lua_thread.create(function()
			local ip, port = sampGetCurrentServerAddress()
			AFKMessage('���������� ��������. ��������� ����� '..arec.wait.v..' ������')
			wait(arec.wait.v * 1000)
			sampConnectToServer(ip,port)
			handle_aurc = nil
		end)
	end
end
--������� ����������
function closeConnect()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, raknetNewBitStream())
	raknetDeleteBitStream(raknetNewBitStream())
end

--//saves
function saveini()
	--login
	mainIni.autologin.state = autologin.state.v
	--autoreconnect
	mainIni.arec.state = arec.state.v
	mainIni.arec.statebanned = arec.statebanned.v
	mainIni.arec.wait = arec.wait.v
	--roulette
	mainIni.roulette.standart = roulette.standart.v
	mainIni.roulette.platina = roulette.platina.v
	mainIni.roulette.donate = roulette.donate.v
	mainIni.roulette.mask = roulette.mask.v
	mainIni.roulette.tainik = roulette.tainik.v
	mainIni.roulette.wait = roulette.wait.v
	--vk.notf
	mainIni.vknotf.state = vknotf.state.v
	mainIni.vknotf.token = vknotf.token.v
	mainIni.vknotf.user_id = vknotf.user_id.v
	mainIni.vknotf.group_id = vknotf.group_id.v
	mainIni.vknotf.isadm = vknotf.isadm.v
	mainIni.vknotf.iscode = vknotf.iscode.v
	mainIni.vknotf.issmscall = vknotf.issmscall.v
	mainIni.vknotf.bank = vknotf.bank.v
	mainIni.vknotf.record = vknotf.record.v
	mainIni.vknotf.ismeat = vknotf.ismeat.v
	mainIni.vknotf.dienable = vknotf.dienable.v
	mainIni.vknotf.isinitgame = vknotf.isinitgame.v	
	mainIni.vknotf.iscloseconnect = vknotf.iscloseconnect.v
	mainIni.vknotf.ishungry = vknotf.ishungry.v
	mainIni.vknotf.isdemorgan = vknotf.isdemorgan.v
	mainIni.vknotf.islowhp = vknotf.islowhp.v
	mainIni.vknotf.ispayday = vknotf.ispayday.v
	mainIni.vknotf.iscrashscript = vknotf.iscrashscript.v
	mainIni.vknotf.issellitem = vknotf.issellitem.v
	--autologin
	mainIni.autologinfix.state = autologinfix.state.v
	mainIni.autologinfix.nick = autologinfix.nick.v
	mainIni.autologinfix.pass = autologinfix.pass.v
	--find
	mainIni.find.vkfind = find.vkfind.v
	mainIni.find.vkfindtext = find.vkfindtext.v
	mainIni.find.vkfindtext2 = find.vkfindtext2.v
	mainIni.find.vkfindtext3 = find.vkfindtext3.v
	mainIni.find.vkfindtext4 = find.vkfindtext4.v
	mainIni.find.vkfindtext5 = find.vkfindtext5.v
	mainIni.find.vkfindtext6 = find.vkfindtext6.v
	mainIni.find.vkfindtext7 = find.vkfindtext7.v
	mainIni.find.vkfindtext8 = find.vkfindtext8.v
	mainIni.find.vkfindtext9 = find.vkfindtext9.v
	mainIni.find.vkfindtext10 = find.vkfindtext10.v
	mainIni.find.inputfindvk = u8:decode(find.inputfindvk.v)
	mainIni.find.inputfindvk2 = u8:decode(find.inputfindvk2.v)
	mainIni.find.inputfindvk3 = u8:decode(find.inputfindvk3.v)
	mainIni.find.inputfindvk4 = u8:decode(find.inputfindvk4.v)
	mainIni.find.inputfindvk5 = u8:decode(find.inputfindvk5.v)
	mainIni.find.inputfindvk6 = u8:decode(find.inputfindvk6.v)
	mainIni.find.inputfindvk7 = u8:decode(find.inputfindvk7.v)
	mainIni.find.inputfindvk8 = u8:decode(find.inputfindvk8.v)
	mainIni.find.inputfindvk9 = u8:decode(find.inputfindvk9.v)
	mainIni.find.inputfindvk10 = u8:decode(find.inputfindvk10.v)
	--piar
	mainIni.piar.piar1 = piar.piar1.v
	mainIni.piar.piar2 = piar.piar2.v
	mainIni.piar.piar3 = piar.piar3.v
	mainIni.piar.piarwait = piar.piarwait.v
	mainIni.piar.piarwait2 = piar.piarwait2.v
	mainIni.piar.piarwait3 = piar.piarwait3.v
	mainIni.piar.auto_piar = piar.auto_piar.v
	mainIni.piar.auto_piar_kd = piar.auto_piar_kd.v
	--main config
	mainIni.config.antiafk = antiafk.v
	mainIni.config.banscreen = banscreen.v
	mainIni.config.autoupdate = autoupdateState.v
	mainIni.config.fastconnect = fastconnect.v
	mainIni.config.autoad = autoad.v
	mainIni.config.autoadbiz = autoadbiz.v
	mainIni.config.autoo = autoo.v
	mainIni.config.atext = atext.v
	mainIni.config.aphone = aphone.v
	--eat
	mainIni.eat.checkmethod = eat.checkmethod.v
	mainIni.eat.cycwait = eat.cycwait.v
	mainIni.eat.eatmetod = eat.eatmetod.v
	mainIni.eat.eat2met = eat.eat2met.v
    mainIni.eat.arztextdrawid = eat.arztextdrawid.v
    mainIni.eat.arztextdrawidheal = eat.arztextdrawidheal.v
    mainIni.eat.setmetod = eat.setmetod.v
    mainIni.eat.hpmetod = eat.hpmetod.v
    mainIni.eat.hplvl = eat.hplvl.v
    mainIni.eat.healstate = eat.healstate.v
	mainIni.eat.drugsquen = eat.drugsquen.v
	mainIni.eat.hpmetod = eat.hpmetod.v
	--buttons
	mainIni.buttons.binfo = binfo.v
	local saved = inicfg.save(mainIni,'afktools.ini')
	AFKMessage('��������� INI ��������� '..(saved and '�������!' or '� �������!'))
end
function saveacc(...)
	local a = {...}

	local data
	if #a == 1 then
		data = temppass[a[1]]
	else
		data = {
			nick = a[1],
			ip = a[4],
			id = a[3],
			text = a[2]
		}
	end
	local id = findAcc(data.nick, data.ip)
	if id > -1 then
		local dId = findDialog(id, data.id)
		if dId == -1 then
			table.insert(savepass[id][3], {
				id = data.id,
				text = data.text
			})
		end
	else
		table.insert(savepass, {
			data.nick,
			data.ip,
			{
				{
					id = data.id,
					text = data.text
				}
			}
		})
	end
end
function saveaccounts()
	if doesFileExist(file_accs) then
		os.remove(file_accs)
	end
	if table.maxn(savepass) > 0 then
		local f = io.open(file_accs, "w")
		if f then
			f:write(encodeJson(savepass))
			f:close()
		end
	end
	print('[Accounts] Saved!')
end
-- // ������� ��������������
updates = {}
updates.data = {
	result = false,
	status = '',
	relevant_version = '',
	url_update = '',
	url_json = 'https://raw.githubusercontent.com/JekSkeez/afktools/main/afktools.json' 
}
function updates:getlast(autoupd)
	print('call getlast')
	self.data.status = '�������� ����������'
	if autoupd then
		AFKMessage(self.data.status)
	end
	local json = path .. '\\updatesarzassistant.json'
	if doesFileExist(json) then os.remove(json) end
	int_json_download = downloadUrlToFile(self.data.url_json, json,
	function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD and id == int_json_download then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					if not info then
						self.data.result = false
						self.data.status = '[decode] ������ ��� �������� JSON �����!\n���������� � ���.��������� �������'
						if autoupd then
							AFKMessage(self.data.status)
						end
						f:close()
						return false
					end
					self.data.result = true
					self.data.url_update = info.updateurl
					self.data.relevant_version = info.latest
					self.data.status = '������ ��������'
					f:close()
					os.remove(json)
					return true
				else
					self.data.result = false
					self.data.status = '[io.open] ���������� ��������� ����������!\n���-�� ��������� ���������� � ��������\n���������� � ���.��������� �������'
					if autoupd then
						AFKMessage(self.data.status)
					end
					return false
				end
			else
				self.data.result = false
				self.data.status = '[exist] ���������� ��������� ����������!\n���-�� ��������� ���������� � ��������\n���������� � ���.��������� �������'
				if autoupd then
					AFKMessage(self.data.status)
				end
				return false
			end
		end
	end)
end

function updates:download()
	if self.data.result and #self.data.relevant_version > 0  then
		if self.data.relevant_version ~= thisScript().version then
			self.data.status = '������� ���������� c '..thisScript().version..' �� '..self.data.relevant_version
			AFKMessage(self.data.status)
			int_scr_download = downloadUrlToFile(self.data.url_update, thisScript().path, function(id3, status1, p13, p23)
				if status1 == dlstatus.STATUS_ENDDOWNLOADDATA and int_scr_download == id3 then
					AFKMessage('�������� ���������� ���������.')
					AFKMessage('���������� ���������!')
					goupdatestatus = true          
					lua_thread.create(function() wait(500) thisScript():reload() end)
				end
				if status1 == dlstatus.STATUSEX_ENDDOWNLOAD and int_scr_download == id3 then
					if goupdatestatus == nil then
						self.data.status = '���������� ������ ��������. �������� ������ ������.'
						AFKMessage(self.data.status)
					end
				end
			end)
		else
			self.data.status = '���������� �� ���������.'
			AFKMessage(self.data.status)
		end
	end
end
function updates:autoupdate()
	local result = self:getlast(true)
	if result then
		self:download()
	end
end
--// �����, ���� � ����
function esstyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	
	style.WindowPadding = imgui.ImVec2(8, 8)
	style.WindowRounding = 4
	style.ChildWindowRounding = 5
	style.FramePadding = imgui.ImVec2(5, 3)
	style.FrameRounding = 3.0
	style.ItemSpacing = imgui.ImVec2(5, 4)
	style.ItemInnerSpacing = imgui.ImVec2(4, 4)
	style.IndentSpacing = 21
	style.ScrollbarSize = 10.0
	style.ScrollbarRounding = 13
	style.GrabMinSize = 8
	style.GrabRounding = 1
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

end
esstyle()

function theme1()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00);
	colors[clr.ChildWindowBg]          = colors[clr.WindowBg];
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00);
    colors[clr.Border]                 = ImVec4(0.60, 0.60, 0.60, 0.40);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.00);
    colors[clr.FrameBg]                = ImVec4(0.36, 0.36, 0.36, 0.30);
    colors[clr.FrameBgHovered]         = ImVec4(0.53, 0.53, 0.53, 0.30);
    colors[clr.FrameBgActive]          = ImVec4(0.62, 0.62, 0.62, 0.30);
    colors[clr.TitleBg]                = ImVec4(0.12, 0.12, 0.12, 0.92);
    colors[clr.TitleBgActive]          = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.11, 0.11, 0.11, 0.85);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.13, 0.13, 0.13, 0.00);
    colors[clr.ScrollbarGrab]          = ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.19, 0.19, 0.19, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.40, 0.40, 0.40, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.23, 0.23, 0.23, 1.00);
    colors[clr.CheckMark]              = ImVec4(0.90, 0.90, 0.90, 1.00);
    colors[clr.SliderGrab]             = ImVec4(0.27, 0.27, 0.27, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(0.24, 0.23, 0.23, 1.00);
    colors[clr.Button]                 = ImVec4(0.36, 0.36, 0.36, 0.40);
    colors[clr.ButtonHovered]          = ImVec4(0.47, 0.46, 0.46, 0.40);
    colors[clr.ButtonActive]           = ImVec4(0.64, 0.64, 0.64, 0.53);
    colors[clr.Header]                 = ImVec4(0.36, 0.36, 0.36, 0.30);
    colors[clr.HeaderHovered]          = ImVec4(0.49, 0.49, 0.49, 0.30);
    colors[clr.HeaderActive]           = ImVec4(0.42, 0.42, 0.42, 0.30);
    colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40);
    colors[clr.SeparatorHovered]       = ImVec4(0.36, 0.36, 0.36, 0.40);
    colors[clr.SeparatorActive]        = ImVec4(0.23, 0.23, 0.23, 0.40);
    colors[clr.ResizeGrip]             = ImVec4(0.36, 0.36, 0.36, 0.30);
    colors[clr.ResizeGripHovered]      = ImVec4(0.49, 0.49, 0.49, 0.30);
    colors[clr.ResizeGripActive]       = ImVec4(0.25, 0.25, 0.25, 0.30);
    colors[clr.CloseButton]            = ImVec4(0.36, 0.36, 0.36, 0.30);
    colors[clr.CloseButtonHovered]     = ImVec4(0.51, 0.51, 0.51, 0.30);
    colors[clr.CloseButtonActive]      = ImVec4(0.22, 0.22, 0.22, 0.30);
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(0.25, 0.25, 0.25, 0.60);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.21, 0.21, 0.21, 0.51);
end

theme1()
local _logos ="\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x28\x00\x00\x00\x28\x08\x06\x00\x00\x00\x8C\xFE\xB8\x6D\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x0B\x13\x00\x00\x0B\x13\x01\x00\x9A\x9C\x18\x00\x00\x00\x20\x63\x48\x52\x4D\x00\x00\x7A\x25\x00\x00\x80\x83\x00\x00\xF9\xFF\x00\x00\x80\xE9\x00\x00\x75\x30\x00\x00\xEA\x60\x00\x00\x3A\x98\x00\x00\x17\x6F\x92\x5F\xC5\x46\x00\x00\x19\x38\x49\x44\x41\x54\x78\x01\x00\x28\x19\xD7\xE6\x01\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x11\x00\x00\x00\x00\x00\x00\x00\x89\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x11\x00\x00\x00\x99\x00\x00\x00\x00\x00\x00\x00\x9A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xBC\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xCC\x00\x00\x00\x33\x00\x00\x00\xEF\x00\x00\x00\x12\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x22\x00\x00\x00\x33\x00\x00\x00\x00\x00\x00\x00\x9A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xAB\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xDD\x00\x00\x00\x22\x00\x00\x00\xDE\x00\x00\x00\x23\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x33\x00\x00\x00\x22\x00\x00\x00\x00\x00\x00\x00\x9A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x33\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xAB\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x77\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\xBB\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xEE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xCC\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xDD\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x11\xFF\xFF\xFF\x77\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x55\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x66\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xAA\xFF\xFF\xFF\x22\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x55\xFF\xFF\xFF\xDD\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xCC\xFF\xFF\xFF\x22\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x99\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x11\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xBB\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\xFF\xFF\xFF\x77\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\xBB\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\xFF\xFF\xFF\x66\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x11\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xAA\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x44\xFF\xFF\xFF\xDD\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xDD\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x77\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x88\xFF\xFF\xFF\x11\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x66\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x66\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x77\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x99\xFF\xFF\xFF\x11\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\xBB\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xDD\xFF\xFF\xFF\x66\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xAA\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x44\xFF\xFF\xFF\xBB\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xDD\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x55\xFF\xFF\xFF\xEE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xBB\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x99\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\x99\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xEE\xFF\xFF\xFF\x77\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x11\xFF\xFF\xFF\x88\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x33\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x77\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x55\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xEE\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xBB\xFF\xFF\xFF\x22\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x33\xFF\xFF\xFF\xBB\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xCC\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xDD\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xDD\xFF\xFF\xFF\x55\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x66\xFF\xFF\xFF\xEE\xFF\xFF\xFF\x44\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x88\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x77\xFF\xFF\xFF\x11\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x11\xFF\xFF\xFF\x11\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x88\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x33\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x22\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\xFF\xFF\xFF\x00\x01\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xDD\x00\x00\x00\x22\x00\x00\x00\xDE\x00\x00\x00\x23\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x33\x00\x00\x00\x22\x00\x00\x00\x00\x00\x00\x00\x9A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x66\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xAB\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xEE\x00\x00\x00\x11\x00\x00\x00\xBC\x00\x00\x00\x45\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x55\x00\x00\x00\x11\x00\x00\x00\x00\x00\x00\x00\xAB\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x55\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xAB\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x11\x00\x00\x00\xBC\x00\x00\x00\xCD\x00\x00\x00\xEF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xFF\xFF\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\xFF\xFF\x04\xE2\xBC\xA7\x45\x71\x94\xC3\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"
logos = imgui.CreateTextureFromMemory(memory.strptr(_logos),#_logos)