script_name('AFK Tools')
script_author("Bakhusse & Mamashin")
script_version('3.3.0')
script_properties('work-in-pause') -- êòî ïðî÷èòàë ó òîãî ïîðâóòñÿ òðóñû

local dlstatus = require("moonloader").download_status
local afkstyle = require("AFKStyles")
local imgui = require('imgui')
local encoding = require("encoding")
local sampev = require("samp.events")
local memory = require("memory")
local effil = require("effil")
local inicfg = require("inicfg")
local ffi = require("ffi")
local fa = require 'faIcons'
local requests = require("requests")
local acef = require("arizona-events")
encoding.default = 'CP1251'
u8 = encoding.UTF8

cefSatiety = nil
cefEatLock = false
local lastEatSatiety = nil
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

if not doesDirectoryExist('moonloader/config/AFKTools') then
	createDirectory('moonloader/config/AFKTools')
end

if not doesDirectoryExist('moonloader/resource/AFKTools/fonts') then
	createDirectory('moonloader/resource/AFKTools/fonts')
end

local path = getWorkingDirectory() .. "\\config\\AFKTools"

local function closeDialog()
	sampSetDialogClientside(true)
	sampCloseCurrentDialogWithButton(0)
	sampSetDialogClientside(false)
end
local fix = false
local use = false
local updateid 
local npc, infnpc = {}, {}
local mainIni = inicfg.load({
	autologin = {
		state = false
	},
	infobar = {
		style = 0,
		custom = "[AFK Tools | {nick}[{id}] | {server}]",
		custom_pos = 0
	},
	arec ={
		state = false,
		statebanned = false,
		wait = 50,
		mode = 0,
		r_min = 0,
		r_max = 0
	},
	roulette = {
		standart = false,
		donate = false,
		platina = false,
		mask = false,
		tainik = false,
		tainikvc = false,
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
		mentions = false,
		taxes = false,
		record = false,
		ismeat = false,
		dienable = false
	},
	tgnotf = {
		token = '',
		user_id = '',
		state = false,
		sellotvtg = true,
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
		mentions = false,
		taxes = false,
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
	tax = {
		state = false,
		setmode = 0,
		exact = 60,
		rand_min = 60,
        rand_max = 120,

        --runtime
        last_ts = 0,
        next_ts = 0,
        running = false,
        worker = nil,
        active = false,
        step = 0
	},
	aoc = {
		setmode = 0,
		wait = 0,

		active = false,
		worker = nil
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
	delplayer = {
    	state = false,
    	cd = 5, 
    	worker = nil,
    	running = false
	},
	delcar = {
    	state = false,
    	cd = 5, 
    	worker = nil,
    	running = false
	},
	buttons = {
		binfo = true
	},
	theme = {
		style = 0
	}

},'AFKTools/AFKTools.ini')


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


if not doesFileExist('moonloader/config/AFKTools/AFKTools.ini') then
	inicfg.save(mainIni,'AFKTools/AFKTools.ini')
end



changelog1 = [[
	v1.0
		Ðåëèç

	v1.1 
		Äîáàâèë àâòîîáíîâëåíèå
		Äîáàâèë íîâûå ñîáûòèÿ äëÿ óâåäîìëåíèé 
		Èçìåíèë àâòîëîãèí, òåïåðü ýòî àâòîçàïîëíåíèå

	v1.2
		Óïðàâëåíèå èãðîé ÷åðåç êîìàíäû: !getplstats, !getplinfo, !send(à òàê æå êíîïêè) 
		Íîâîå ñîáûòèå äëÿ îòïðàâêè óâåäîìëåíèÿ: ïðè âûõîäå èç äåìîðãàíà
		Äîáàâèë ôëóäåð íà 3 ñòðîêè(åñëè 2 èëè 3 ñòðîêà íå íóæíà îñòàâüòå å¸ ïóñòîé)
	
	v1.25 - Hotfix
		Èñïðàâèë êðàø ïðè îòïðàâêå óâåäîìëåíèÿ î òîì ÷òî ïåðñ ãîëîäåí

	v1.3
		Äîáàâèë îòêðûòèå äîíàò ñóíäóêà (âíèìàòåëüíî ÷èòàéòå êàê ñäåëàòü ÷òîá ðàáîòàëî)
		Äëÿ óêðàèíöåâ: äîáàâèë âîçìîæíîñòü âûðóáèòü VK Notifications è ñïîêîéíî èñïîëüçîâàòü ñêðèïò

	v1.4
		Ïîôèêñèë àâòîîòêðûòèå åñëè èãðà ñâåðíóòà

	v1.5
		Ïåðåïèñàë ôóíêöèþ ïðèíÿòèÿ óâåäîìëåíèé
		Òåïåðü àâòîõèëë íå ôëóäèò

	v1.6
		Ðåëèç íà BlastHack
		Ê êàæäîé ñòðîêå ôëóäåðà äîáàâëåíà ñâîÿ çàäåðæêà
		Òåïåðü, åñëè âàñ óáèë èãðîê è âêëþ÷åíî óâåäîìëåíèå î ñìåðòè, â óâåäîìëåíèè íàïèøåò êòî âàñ óáèë
		Ïðèáðàëñÿ â êîäå

	v1.6.1
		Ôèêñ VK Notifications

	v1.7
		Â VK Notifications äîáàâëåíà êíîïêà "Ãîëîä" è êîìàíäà !getplhun
		Äîáàâëåíà âîçìîæíîñòü âûêëþ÷èòü àâòîîáíîâëåíèå
		Èñïðàâëåíû ëîæíûå óâåäîìëåíèÿ íà ñîîáùåíèÿ îò àäìèíèñòðàòîðà\

	v1.8 
		Îáíîâèë ñïîñîá àíòèàôê, âðîäå òåïåðü ó âñåõ ðàáîòàåò
		Ïîôèêñèë åñëè ïåðñ óìðåò

	v1.8-fix
		Ôèêñ êðàøà ïðè ðåêîííåêòå

	v1.9
		Íîâûé äèçàéí
		Äîáàâëåí ÀâòîÏèàð
		Äîáàâëåíà ïðîâåðêà íà /pm îò àäìèíîâ(äèàëîã + ÷àò, 2 âèäà)
		Ôèêñ AutoBanScreen - òåïåðü, ñêðèíèò ïðè ïîÿâëåíèè äèàëîãà î áàíå

	v1.9.1
		Ôèêñ õàâêè èç äîìà

	v1.9.1.1
		Ôèêñ ñîõðàíåíèÿ çàäåðæêè äëÿ àâòîîòêðûòèÿ

	v2.0.0
		Ïîôèêøåíû êðàøè(âðîäå âñå) ïðè ðåêîííåêòå, èñïîëüçîâàíèè áîòà VK
		Ñìåíåí äèçàéí íà áîëåå ïðèÿòíûé
		Â àâòîçàïîëíåíèå äîáàâëåíà êíîïêà "Äîáàâèòü àêêàóíò"
		Äîáàâëåíû êîìàíäû /afkrec(ðåêîí ñ ñåêóíäàìè), /afksrec(ñòîïàåò àâòîðåêîí è ðåêîí îáû÷íûé)

		]]
changelog2 = [[	v2.0.1
		Ôèêñ àâòîîòêðûòèÿ

	v2.0.2
		Àâòîåäà - Äîáàâëåí âûáîð ïðîâåðêè êîãäà ìîæíî ïîõàâàòü(ïîëîñêà ãîëîäà ñ íàñòðîéêîé) 
		Ôèêñ êðàøåé èç-çà ïèàðà è äð.
		Äîáàâëåí Fastconnect

	v2.0.3
		Ôèêñû áàãîâ

	v2.0.4
		Îòêëþ÷åíèå àâòîîáíîâëåíèé
		Â VK Notifications äîáàâëåíà êíîïêà "SMS è Çâîíîê"

	v2.0.5
		Â VK Notifications äîáàâëåíà êíîïêà "ÊÄ ìåøêà/ðóëåòîê", à òàêæå "Êîä ñ ïî÷òû/ÂÊ"
		Äîáàâëåíû êîìàíäû !sendcode !sendvk äëÿ îòïðàâêè êîäîâ ïîäòâåðæäåíèé èç ÂÊ â èãðó.

	v2.0.6
		Äîáàâëåí Àâòîîòâåò÷èê, êîòîðûé ñàì âîçüìåò òðóáêó è ïîïðîñèò àáîíåíòà íàïèñàòü â ÂÊ.
		Äîáàâëåíà çàïèñü çâîíêîâ, òàêæå ìîæíî ðàçãîâàðèâàòü ïî òåëåôîíó èç ÂÊ.
		Â ÂÊ äîáàâëåíû êîìàíäû !p (ïðèíÿòü çâîíîê) è !h (ñáðîñèòü çâîíîê). Îáùàòüñÿ ìîæíî ÷åðåç !send [òåêñò].

	v2.0.7
		Åñëè â àâòîïèàðå èñïîëüçóåòå /ad, òî äëÿ ýòîãî äîáàâëåí Àâòîñêèï /ad (äëÿ îáû÷íûõ è ìàðêåòîëîãîâ).
		Ïîôèêñèë ôëóä â ÂÊ "The server didn't respond".
		Âîññòàíîâëåíèå íà ÁÕ.

	v2.0.8
		Äîáàâèë ïðîâåðêó ïðè èñïîëüçîâàíèè êîìàíäû !p, !h (ðàíüøå ñêðèïò îòïðàâëÿë ñîîáùåíèÿ äàæå íå âçàèìîäåéñòâóÿ)
		Òåïåðü ñêðèïò íå ðåñòàðòèò ïðè çàïðîñå êîäà ñ ïî÷òû/ÂÊ.
		Ïåðåïèñàí àâòîîòâåò÷èê, à òàêæå çàïèñü çâîíêîâ.
		Òåïåðü åñòü 2 âåðñèè ñêðèïòà:
			- Ñ óæå ïîäêëþ÷åííûì ïàáëèêîì (äëÿ òåõ êòî íå óìååò)
			- Áåç ïîäêëþ÷åííîãî ïàáëèêà, ïîäêëþ÷àòü ñàìîìó (äëÿ òåõ êòî õî÷åò áûòü êðóòûì)
		Äîáàâëåíà êîìàíäà !gauth äëÿ îòïðàâêè êîäà èç GAuthenticator
		Åñëè ïåðñîíàæ çàñïàíèòñÿ ïîñëå ëîãèíà, òî ïðèäåò óâåäîìëåíèå
		
		]]
changelog3 = [[
	v2.0.9
		Òåïåðü íà àâòîîòâåò÷èê ìîæíî ïèñàòü ñâîé òåêñò.
		Â ÂÊ äîáàâëåíà êíîïêà "Ïîñëåäíèå 10 ñòðîê ñ ÷àòà"
		Äîáàâëåíà ôóíêöèÿ ïåðåîòïðàâêè ñîîáùåíèÿ â /vr èç-çà ÊÄ.
		Òåïåðü ñêðèïò ïîääåðæèâàåò àâòîîáíîâëåíèå.

	v2.0.9.1
		Íåáîëüøîé áàãîôèêñ.
		Ïåðåïèñàí ñêèï /ad.

	v2.0.9.2
		Ïåðåïèñàí ïîëíîñòüþ àâòîîòâåò÷èê è îòâåò íà çâîíêè ñ ÂÊ.
		Èñïðàâëåíû áàãè.

	v2.1.0
		Èñïðàâëåíà ðàáîòà Àâòîñêèïà äèàëîãà /vr.
		Òåïåðü ìîæíî âêëþ÷àòü îòïðàâêó âñåõ äèàëîãîâ â ÂÊ.
		Äîáàâëåíî âçàèìîäåéñòâèå ñ äèàëîãàìè â èãðå ÷åðåç !d [ïóíêò èëè òåêñò] è !dc (çàêðûâàåò äèàëîã).
		Òåïåðü îòïðàâëÿòü êîìàíäû â èãðó ìîæíî áåç !send, íî îòïðàâëÿòü òåêñò â ÷àò ÷åðåç íåãî âñå æå íóæíî.
		Ïðèïîäíÿë êíîïêè â ãëàâíîì ìåíþ äëÿ êðàñîòû.
		Ïðèáðàëñÿ â îñíîâíûõ íàñòðîéêàõ.
		Ïîôèêñèë àâòîîòêðûòèå, äîáàâèë äîï. ñóíäóêè.

	v2.2
		Òåïåðü ñêðèíøîò èç èãðû ìîæíî ïîëó÷àòü â ÂÊ.
		Äîáàâèë íåñêîëüêî êíîïîê äëÿ ñêà÷èâàíèÿ áèáëèîòåê/äðóãèõ ñêðèïòîâ:
			 Àâòîîòêðûòèå îò bakhusse
			 AntiAFK by AIR
			 Áèáëèîòåêè äëÿ ðàáîòû !screen
		Óìåíüøèë ðàçìåðû îêîí "Êàê íàñòðîèòü" è "Êàê èñïðàâèòü !screen" â VK Notifications.
		Èñïðàâèë àâòîîáíîâëåíèå â âåðñèè ñ ïàáëèêîì.
		Äîáàâëåíû êíîïêè:
			 OK è Cancel äëÿ äèàëîãîâûõ îêîí
			 ALT
			 ESC äëÿ çàêðûòèÿ TextDraw
		Äîáàâèë óâåäîìëåíèå îò ïîëó÷åíèÿ èëè îòïðàâëåíèÿ áàíêîâñêîãî ïåðåâîäà.
		Â êíîïêó "Ïîääåðæêà" áûëè äîáàâëåíû íîâûå êîìàíäû.
		Ïåðåïèñàí òåêñò â "Êàê íàñòðîèòü" â VK Notifications.
		Òåïåðü ïðè âêëþ÷åííîé ôóíêöèè "Îòïðàâêà âñåõ äèàëîãîâ" ñîîáùåíèÿ íå îòïðàâëÿþòñÿ ïî 2 ðàçà.
		Äîáàâëåí ïîêàçàòåëü îíëàéíà íà ñåðâåðå â "Èíôîðìàöèÿ"

]]
changelog4 = [[
	v2.3
		Òåïåðü êíîïêè óïðàâëåíèÿ èãðîé îòäåëüíû îò îñíîâíîé êëàâèàòóðû.
		Èñïðàâèë êðàø èãðû îò êíîïêè ALT èç ÂÊ.
		Çàìåíèë êíîïêè Ïåðåîòïðàâêà /vr è Ñêèï /vr íà êíîïêó ñêà÷èâàíèÿ ñêðèïòà îò Cosmo.
		Äîáàâëåíà îòïðàâêà íàéäåííîãî òåêñòà â ÂÊ.
		Äîáàâèë ññûëêè íà ãðóïïó ÂÊ, ÂÊ Ðàçðàáîò÷èêà, Telegram-êàíàë.
		Ïðè îòïðàâêå äèàëîãîâûõ îêîí êíîïêè áóäóò â ñîîáùåíèè 
			(äëÿ òåõ äèàëîãîâ áåç âûáîðà ñòðîêè è ââîäà òåêñòà).
		Òåïåðü ÷åðåç ÂÊ ìîæíî âûêëþ÷èòü èãðó è êîìïüþòåð(ñ òàéìåðîì íà 30 ñåê.)
		Âûðåçàíà ôóíêöèÿ ñêèï äèàëîãà /ad íà äîðàáîòêó.
		Äîáàâèë ôóíêöèþ "Óáðàòü ëþäåé â ðàäèóñå".
		Äîáàâèë äîï. ñîâåò äëÿ èñïîëüçîâàíèÿ !screen.

	v2.4
		Òåïåðü äèàëîã îá îòïðàâêå ñîîáùåíèÿ â /vr íå áóäåò îòïðàâëÿòüñÿ â ÂÊ.
		Äîáàâëåíû êíîïêè Ïðèíÿòü/Îòêëîíèòü çâîíîê ïðè âõîäÿùåì âûçîâå â ÂÊ.
		Èñïðàâëåí àâòîîòâåò÷èê, ðàíåå íå íàæèìàë Y è íå áðàë òðóáêó.
		Äîáàâëåíà êíîïêà Ñêðèíøîò â äèàëîãå â ÂÊ.
		Äîáàâëåíà êíîïêà äëÿ ñêà÷èâàíèÿ ñêðèïòà ñ ïàáëèêîì èëè áåç.

	v2.5
		Èñïðàâèë àâòîåäó â ôàì ÊÂ.
		Â ÀâòîÕèë äîáàâëåíû ñèãàðåòû

	v2.5.1 HOTFIX
		Â îñíîâíûå íàñòðîéêè äîáàâëåí àâòîëîãèí äëÿ íîâûõ èíòåðôåéñîâ.

]]

changelog5 = [[

	v3.0 Beta

		· Äîáàâëåíî Telegam Notifications [Beta]
		· Äîáàâëåí ðàçäåë êàñòîìèçàöèè [Beta]
		· Ãëîáàëüíûå èçìåíåíèÿ âèçóàëüíîãî èíòåðôåéñà ñêðèïòà
		· ×àñòè÷íî ïåðåïèñàíû íåêîòîðûå ðàçäåëû 
		· Äîáàâëåí faIcons.lua êàê çàâèñèìîñòü 
		· Äîáàâëåíû FreeStyle ImGui òåìû 
		· Äîáàâëåíà ñâåòëàÿ AFKTools òåìà [Beta]
		· Ðåàëèçîâàí AFKStyles.lua êàê çàâèñèìîñòü(?) [Beta]
		· Ïîèñê â ÷àòå äëÿ VK + Telegram
		· Îáíîâë¸í ëîãîòèï â øàïêå ñêðèïòà
		· Äîáàâëåí ëîãîòèï â AFKMessage
		· Ïîëíîñòüþ ïåðåïèñàí ðàçäåë Èíôîðìàöèÿ è F.A.Q
		· ×àñòè÷íî ïåðåïèñàí ðàçäåë îñíîâíûõ ôóíêöèé â áîëåå ïðèåìëåìûé âèä
		· Â ðàçäåë èíôîðìàöèè äîáàâëåí script_banner.png
		· Config ïðåîáðàçîâàí â AFKTools.ini
		· Ðàáî÷àÿ äèðåêòîðèÿ êîíôèãà - /moonloader/config/AFKTools/...
		· Çàäåéñòâîâàíà ïàïêà resource
		· Config ÷àñòè÷íî ïî÷èùåí îò ëèøíèõ ïåðåìåííûõ
		· Óäàëåíû ëèøíèå êíîïêè
		· Óäàë¸í óñòàðåâøèé ãàéä ïî íàñòðîéêå API ÂÊîíòàêòå
		· Óäàëåíà âåðñèÿ ñ ïàáëèêîì
		· Óäàë¸í àâòîîòâåò÷èê 

]]
changelog6 = [[

	v3.1.0 

		· Èñïðàâëåíû íåáîëüøèå è áîëüøèå áàãè
		· Óøëè â äîëãèé çàïîé (íà 2-3 ãîäà...)

	v3.2.0 

		· Èñïðàâëåíî óâåäëîìëåíèå î PayDay
		· Äîáàâëåí íîâûé ñïîñîá ïðîâåðêè ãîëîäà - CEF
		· Äîáàâëåí íîâûé ïóíêò óâåäîìåíèé - Óïîìèíàíèÿ
		· Äîáàâëåíà êîìàíäà äëÿ âêëþ÷åíèÿ àâòîîòêðûòèÿ ðóëåòîê - /autorul
		· Äîáàâëåíà àâòîîïëàòà íàëîãîâ ñ âûáîðîì ÊÄ: òî÷íîå èëè ðàíäîì
		· Äîáàâëåíà âîçìîæíîñòü âûáèðàòü çàäåðæêó àâòîðåêîííåêòà: òî÷íàÿ èëè ðàíäîì
		· Óáðàí àâòîëîãèí, íà çàìåíó íåìó ïðèøåë àâòîëîãèí ARZ
		· Äîðàáîòàíà ôóíêöèÿ Óäàëÿòü èãðîêîâ â ðàäèóñå, òåïåðü ìîæíî óêàçàòü ÊÄ çà êîòîðîå èãðîêè â ðàäèóñå áóäóò ïðîïàäàòü
		· Äîáàâëåíî Óäàëåíèå ìàøèí â ðàäèóñå

	v3.3.0 

		· Äîáàâëåí íîâûé ìåòîä îòêðûòèÿ ñóíäóêîâ è òàéíèêîâ, è àêòèâíîãî àêññåñóàðà "Îáðåç" - CEF
		· Òåïåðü êîìàíäà /autorul âûïîëíÿåò òîò ìåòîä îòêðûòèÿ, êîòîðûé áûë âûáðàí â ñêðèïòå
		· Äîáàâëåíî óâåäîìëåíèå îá îïëàòå íàëîãîâ
		· Òåïåðü òåëåôîí óáèðàåòñÿ ïîñëå îïëàòû íàëîãîâ
		· Äîáàâëåíà èíñòðóöèÿ ïî èñïðàâëåíèþ ÒÃ
		· Èñïðàâëåí áàã, êîãäà ïðè àâòîðèçàöèè ñêðèïò ïûòàëñÿ ïîêóøàòü ïðè ñïîñîáå ïðîâåðêè ãîëîäà - CEF
		· Òåïåðü â ÷åðåç àâòîïèàð ìîæíî îòïðàâëÿòü êîìàíäû äðóãèõ ñêðèïòîâ (íàïðèìåð /vra ÷åðåç VIP-Resend îò Cosmo)
		· Ïðè ïðîïóùåííîì âûçîâå òåëåôîí áóäåò óáèðàòüñÿ àâòîìàòè÷åñêè, ÷òîáû íå ìåøàòü ðàáîòå àâòîîïëàòû íàëîãîâ è àâòîîòêðûòèÿ ðóëåòîê
		· Èçìåíåíà ðàáîòà óâåäîìëåíèÿ "Êðàø ñêðèïòà", ïåðåäåëàíà â "Êðàø/çàïóñê ñêðèïòà", áóäóò ïîñòóïàòü òàêæå óâåäîìëåíèÿ î çàïóñêå
		· Â ðàçäåë Îñíîâíîå äîáàâëåíà êíîïêà íà ñêà÷èâàíèå AFKTools reloader, êîòîðàÿ ïåðåçàïóñòèò ñêðèïò ïî êîìàíäå !afkreload èç VK/TG
		· Â ðàçäåëå Êàñòîìèçàöèÿ îáàâëåíà âîçìîæíîñòü ðåäàêòèðîâàòü èíôîáàð â óâåäîìëåíèÿõ, à òàêæå êàñòîìèçèðîâàòü åãî!

]]

scriptinfo = [[
 AFK Tools - ñêðèïò, äëÿ ïðîêà÷êè àêêàóíòà íà Arizona Role Play!
Â äàííîì ðàçäåëå âû ìîæåòå íàéòè ññûëêè íà ñîö-ñåòè ïðîåêòà(AFKTools), òåì ñàìûì áîëüøå óçíàòü î ñêðèïòå.

Ïî âîïðîñàì ïî ñêðèïòó, ïîääåðæêå, òåõ.ïîääåðæêå, ïîìîùè, îáðàùàòüñÿ ê  - Mamashin
Òàê æå, ðåêîìåíäóåì âñòóïèòü â íàøå ñîîáùåñòâî ÂÊîíòàêòå è â áåñåäó ïîëüçîâàòåëåé!

Ðàçðàáîòêà/Ïîääåðæêà ñêðèïòà: Bakhusse & Mamashin/S-Mamashin

Àâòîð ïðîåêòà: Neverlane(ronnyevans)

Îòäåëüíîå ñïàñèáî: Cosmo çà ìîðàëüíóþ ïîääåðæêó!

2020-2023. 2026.
]]


scriptcommand = [[

	Îñíîâíûå êîìàíäû ñêðèïòà:

		/afktools - îòêðûòü ìåíþ ñêðèïòà
		/afkreload - ïåðåçàãðóçèòü ñêðèïò 
		/afkunload - âûãðóçèòü ñêðèïò
		/afkrec - ðåêîííåêò ñ ñåêóíäàìè
		/afksrec - îñòàíîâèòü ðåêîííåêò(ñòàíäàðòíûé èëè àâòîðåêîí)
		/autorul - âêëþ÷èòü àâòîîòêðûòèå ðóëåòîê

]]

howsetVK = [[
Åñëè âàì íå äîâåëîñü èìåòü äåëî ñ API ÂÊîíòàêòå, âû íå çíàåòå, ÷òî òàêîå "Òîêåí",
íå èìååòå ïîëíîãî ïðåäñòàâëåíèÿ ãäå âçÿòü VK ID/PUBLIC ID - ïðèãëàøàåì âàñ â íàøå ñîîáùåñòâî ÂÊîíòàêòå.

Ó íàñ åñòü àêòèâíûé ÷àò ïîëüçîâàòåëåé â êîòîðîì âû ìîæåòå ïîïðîñèòü ïîìîùè íà ýòó äîëþ. 
Èìååòñÿ ñòàòüÿ, ñ ïîäðîáíûì ãàéäîì ïî íàñòðîéêå VK API.
Òàê æå, ïðèñóòñòâóåò âèäåîàäàïòàöèÿ ãàéäà äëÿ òåõ, êòî íå ëþáèòåëü ÷èòàòü.

Èñïîëüçóéòå êíîïêè íèæå, ÷òîáû ïåðåéòè íà èñòî÷íèêè.

]]

howsetTG = [[
Â Telegram âñ¸ êóäà ñëàùå è ïðîùå ÷åì ñ VK API. 
Äà áû íå ïåðåïèñûâàòü îäíî è òîæå ïî 100 ðàç, ìû ðåøèëè èñïîëüçîâàòü åäèíûé ïîëíîöåííûé ãàéä.

Ãàéä âêëþ÷àåò â ñåáÿ ïîëíîöåííóþ ïðîöåäóðó ðåàëèçàöèè ïîëó÷åíèÿ óâåäîìëåíèé â Telegram, øàã çà øàãîì.

Òàê æå ó íàñ èìååòñÿ ÷àò ïîëüçîâàòåëåé â êîòîðîì âû ìîæåòå ñïðîñèòü ïîìîùè. 

Èñïîëüçóéòå êíîïêè íèæå, ÷òîáû ïåðåéòè íà èñòî÷íèêè

]]

helpTG = [[
Ñêðèïò íå ðåàãèðóåò íà êíîïêè èëè òåêñò â ÒÃ ÷àòå?

Ýòî äîâîëüíî-òàêè ëåãêî èñïðàâèòü, è íåò, ýòî íå ïðîáëåìà ñêðèïòà.

Çàéäè â @BotFather, âûáåðè ñâîåãî áîòà ïî êîìàíäå /mybots, âûáåðè Bot Settings.

Òåïåðü íóæíî îòêëþ÷èòü Allow Groups è Group Privacy ïî êíîïêå Turn off.

Åùå ëåã÷å ìîæíî ñäåëàòü â ìèíè-ïðèëîæåíèè BotFather, òàì âûáèðàåòå áîòà.

Ïîñëå Bot Settings è îòêëþ÷àåòå òå æå ïàðàìåòðû.

]]

customtext = [[

Äàííûé ðàçäåë íàõîäèòñÿ íà ñòàäèè ðàçðàáîòêè!

Â äàííîì ðàçäåëå âû ìîæåòå íàêîíåö-òî èçìåíèòü ImGUI ñîñòàâëÿþùóþ íàøåãî ñêðèïòà!
Çàäåéñòâîâàí ôðèñòàéë ñ BlastHack, à òàê æå îðèãèíàëüíûå òåìû íà îñíîâå íàøåé îñíîâíîé òåìû!

]]

prefixtext = [[
Ïðåôèêñû îôîðìëåíèÿ:
[AFKTools] - òåìû ñäåëàííûå íà îñíîâå ëåãåíäàðíîé, ñòàíäàðòíîé, ðîäíîé òåìû AFKTools.
[BlastHack] - òåìû ôîðìàòà "Free-style", âçÿòû ñ îòêðûòîãî äîñòóïà îò ðàçðàáîò÷èêîâ è äèçàéíåðîâ BlastHack.
[NickName] - òåìà îïóáëèêîâàííàÿ èçâåñòâåíûì ðàçðàáîò÷èêîì/UI-äèçàéíåðîì íà BlastHack.

]]

searchchatfaq = [[
	
Ïîèñê è îòïðàâêà òåêñòà ñ ñåðâåðà - ïðÿìî âàì â Telegram èëè ÂÊîíòàêòå.
Åñëè âêëþ÷åí òîëüêî ðàçäåë "VK Notifications" - óâåäîìëåíèÿ áóäóò ïðèõîäèòü òîëüêî â VK.
Åñëè âêëþ÷åí òîëüêî ðàçäåë "TG Notifications" - óâåäîìëåíèÿ áóäóò ïðèõîäèòü òîëüêî â Telegram.
Åñëè ïîëó÷àåòå óâåäîìëåíèÿ â îáà ìåññåíäæåðà - íàéäåííûé òåêñò áóäåò îòïðàâëÿòüñÿ âàì è â VK è â Telegram.

Äëÿ ÷åãî ýòî?
Ïðåäóñìîòðåíî 10 ïîëåé ôîðìàòà Input, ââåäèòå â îäèí èç íèõ íóæíûé òåêñò(Ïðèìåð: Øàð + 12), ïîñòàâüòå ãàëî÷êó ðÿäîì è ñêðèïò áóäåò âàì
îòïðàâëÿòü, âñå ñòðîêè ñâÿçàííûå ñ "Øàð +12", àíàëîãè÷íî ñ äðóãèìè àêñåññóàðàìè, òðàíñïîðòîì è äðóãèì èìóùåñòâîì.
Òàê æå, ìîæåòå âûëàâëèâàòü íóæíûå äëÿ âàñ ñòðîêè ñ ïîìîùüþ ýòîé ôóíêöèè, íàïðèìåð äåéñòâèÿ îïðåäåë¸ííîãî èãðîêà â ïëàíå /ad /vr /fam è òä.
]]


howscreen = [[
Êîìàíäà !screen ðàáîòàåò ñëåäóþùèì îáðàçîì:
 Åñëè èãðà ñâ¸ðíóòà - ïðîèçîéäåò êðàø ñêðèïòà
 Åñëè èãðà íà âåñü ýêðàí - ïðèä¸ò ïðîñòî áåëûé ñêðèíøîò. 
 ×òîáû ñðàáîòàëî èäåàëüíî - íóæíî ñäåëàòü èãðó â îêîííûé ðåæèì 
  è ðàñòÿíóòü íà âåñü ýêðàí (íà ëàóí÷åðå ìîæíî ïðîñòî â íàñòðîéêàõ
  ëàóí÷åðà âêëþ÷èòü îêîííûé ðåæèì).
 Äëÿ ðàáîòû êîìàíäû íóæíî ñêà÷àòü íåîáõîäèìûå
  áèáëèîòåêè (ñêà÷àòü ìîæíî â ìåíþ VK/TG Notifications)
 ×òîáû ïîëó÷àòü ñêðèíû êîððåêòíî, ñîâåòóþ ñïåðâà èñïîëüçîâàòü
  êîìáèíàöèþ Alt + Enter, ïîñëå Win + ñòðåëêà ââåðõ.
]]

local _message = {}

local chat = "https://vk.me/join/OznKTxWIyyzo20jNxgdqqNkop85ZPJE1Xa0="

local style_selected = imgui.ImInt(mainIni.theme.style) 
local style_list = {u8"Îðèãèíàëüíàÿ", u8'Ñâåòëàÿ', u8"Ñåðàÿ", u8"Ò¸ìíàÿ", u8"Âèøí¸âàÿ", u8"Ôèîëåòîâàÿ", u8"Ðîçîâàÿ"}

local banner = imgui.CreateTextureFromFile(getWorkingDirectory() .. "\\resource\\AFKTools\\script_banner.png")


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

local infobar = {
	style = imgui.ImInt(mainIni.infobar.style),
	custom = imgui.ImBuffer(mainIni.infobar.custom, 256),
	custom_pos = imgui.ImInt(mainIni.infobar.custom_pos)
}

local autologin = {
	state = imgui.ImBool(mainIni.autologin.state)
}
local arec = {
	state = imgui.ImBool(mainIni.arec.state),
	statebanned = imgui.ImBool(mainIni.arec.statebanned),
	wait = imgui.ImInt(mainIni.arec.wait),

	mode = imgui.ImInt(mainIni.arec.mode),
	r_min = imgui.ImInt(mainIni.arec.r_min),
	r_max = imgui.ImInt(mainIni.arec.r_max)
}
local roulette = {
	standart = imgui.ImBool(mainIni.roulette.standart),
	donate = imgui.ImBool(mainIni.roulette.donate),
	platina = imgui.ImBool(mainIni.roulette.platina),
	mask = imgui.ImBool(mainIni.roulette.mask),
	tainik = imgui.ImBool(mainIni.roulette.tainik),
	tainikvc = imgui.ImBool(mainIni.roulette.tainikvc),
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
	mentions = imgui.ImBool(mainIni.vknotf.mentions),
	taxes = imgui.ImBool(mainIni.vknotf.taxes),
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

local tgnotf = {
	token = imgui.ImBuffer(''..mainIni.tgnotf.token,300),
	user_id = imgui.ImBuffer(''..mainIni.tgnotf.user_id,300),
	state = imgui.ImBool(mainIni.tgnotf.state),
	isinitgame = imgui.ImBool(mainIni.tgnotf.isinitgame),
	sellotvtg = imgui.ImBool(mainIni.tgnotf.sellotvtg),
    ishungry = imgui.ImBool(mainIni.tgnotf.ishungry),
    issmscall = imgui.ImBool(mainIni.tgnotf.issmscall),
    bank = imgui.ImBool(mainIni.tgnotf.bank),
    mentions = imgui.ImBool(mainIni.tgnotf.mentions),
    taxes = imgui.ImBool(mainIni.tgnotf.taxes),
    record = imgui.ImBool(mainIni.tgnotf.record),
    ismeat = imgui.ImBool(mainIni.tgnotf.ismeat),
    dienable = imgui.ImBool(mainIni.tgnotf.dienable),
    iscloseconnect = imgui.ImBool(mainIni.tgnotf.iscloseconnect),
    isadm = imgui.ImBool(mainIni.tgnotf.isadm),
    iscode = imgui.ImBool(mainIni.tgnotf.iscode),
    isdemorgan = imgui.ImBool(mainIni.tgnotf.isdemorgan),
    islowhp = imgui.ImBool(mainIni.tgnotf.islowhp),
    issendlowhp = false,
    ispayday = imgui.ImBool(mainIni.tgnotf.ispayday),
    iscrashscript = imgui.ImBool(mainIni.tgnotf.iscrashscript),
    ispaydaystate = false,
    ispaydayvalue = 0,
    ispaydaytext = '',
    issellitem = imgui.ImBool(mainIni.tgnotf.issellitem)
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
local tax = {
	state = imgui.ImBool(mainIni.tax.state),
	setmode = imgui.ImInt(mainIni.tax.setmode),
	exact = imgui.ImInt(mainIni.tax.exact),
	rand_min = imgui.ImInt(mainIni.tax.rand_min),
	rand_max = imgui.ImInt(mainIni.tax.rand_max)
}
local delplayer = {
	state = imgui.ImBool(mainIni.delplayer.state),
	cd = imgui.ImInt(mainIni.delplayer.cd)
}
local delcar = {
	state = imgui.ImBool(mainIni.delcar.state),
	cd = imgui.ImInt(mainIni.delcar.cd)
}
local aoc = {
	setmode = imgui.ImInt(mainIni.aoc.setmode),
	wait = imgui.ImInt(mainIni.aoc.wait)
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
		AFKMessage('Ðåàãèðóþ, êóøàþ')
		gotoeatinhouse = true
		sampSendChat('/home')
	elseif eat.eatmetod.v == 3 then
		AFKMessage('Ðåàãèðóþ, êóøàþ')
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
		AFKMessage('Ðåàãèðóþ, êóøàþ')
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
            sampSendChat("/mn")
			wait(2000)
			sampCloseCurrentDialogWithButton(0)
            wait(2000)
            fix = false
			AFKMessage('Íà÷èíàåì äåëàòü ïðîâåðêó')
			checkopen.standart = true
			checkopen.donate = roulette.donate.v and true or false
			checkopen.platina = roulette.platina.v and true or false
			checkopen.mask = roulette.mask.v and true or false
			checkopen.tainik = roulette.tainik.v and true or false
			sampSendChat('/invent')
			wait(roulette.wait.v*60000)
			AFKMessage('Ïåðåçàïóñê')
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

-- Ìåòîä ïîëó÷åíèÿ ñòàòóñà ãîëîäà -- 

local checklist = {
	u8('You are hungry!'),
	u8('Ïîëîñêà ãîëîäà'),
	u8('CEF')
}

-- Õàâêà -- 

local metod = {
	u8('×èïñû'),
	u8('Ðûáà'),
	u8('Îëåíèíà'),
	u8('TextDraw'),
	u8('Ìåøîê')
}

-- Íàëîãè -- 

local taxmode = {
	u8('Òî÷íîå ÊÄ'),
	u8('Ïðèìåðíîå ÊÄ')
}

local aocmode = {
	u8('Ñòàðîå àâòîîòêðûòèå (TextDraw)'),
	u8('Íîâîå àâòîîòêðûòèå (CEF)')
}

-- àâòîðåêîííåêò -- 

local arecmode = {
	u8('Òî÷íàÿ çàäåðæêà'),
	u8('Ïðèìåðíàÿ çàäåðæêà')
}

-- Õèëêè -- 

local healmetod = {
	u8('Àïòå÷êà'),
	u8('Íàðêîòèêè'),
	u8('Àíäðåíàëèí'),
	u8('Ïèâî'),
	u8('TextDraw'),
	u8('Ñèãàðåòû')
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

function threadHandle(runner, url, args, resolve, reject) -- îáðàáîòêà effil ïîòîêà áåç áëîêèðîâîê
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

function evalcef(code)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 17)
    raknetBitStreamWriteInt32(bs, 0)
    raknetBitStreamWriteInt16(bs, #code)
    raknetBitStreamWriteInt8(bs, 0)
    raknetBitStreamWriteString(bs, code)
    raknetEmulPacketReceiveBitStream(220, bs)
    raknetDeleteBitStream(bs)
end

function closeInventory()
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)

    local msg = "inventoryClose"
    raknetBitStreamWriteInt16(bs, #msg)
    raknetBitStreamWriteString(bs, msg)

    raknetSendBitStreamEx(bs, 1, 7, 1)
    raknetDeleteBitStream(bs)
end

function newaoc()
    if aoc.active then
        stopNewAOC()
        AFKMessage('Íîâîå àâòîîòêðûòèå îñòàíîâëåíî')
    else
        startNewAOC()
        AFKMessage('Íîâîå àâòîîòêðûòèå çàïóùåíî')
    end
end

function startNewAOC()
    if aoc.worker then return end

    aoc.active = true

    aoc.worker = lua_thread.create(function()
        while aoc.active do
            runNewAOC()

            local waitMin = aoc.wait.v
            if waitMin < 1 then waitMin = 1 end

            wait(waitMin * 60 * 1000)
        end

        aoc.worker = nil
    end)
end

function stopNewAOC()
    aoc.active = false

    if aoc.worker then
        aoc.worker:terminate()
        aoc.worker = nil
    end
end

function runNewAOC()
    sampSendChat('/invent')

    lua_thread.create(function()
        wait(3000)

        local auto_js = [[
            (function() {
                let items = document.querySelectorAll('.inventory-item');
                let targets = ['569','1424','1854','3926','5823','9761', '5822'];
                let delay = 0;

                items.forEach((item) => {
                    let img = item.querySelector('img');
                    if (!img) return;

                    let isTarget = targets.some(id =>
                        img.src.includes(id) || img.alt.includes(id)
                    );

                    if (isTarget) {
                        setTimeout(() => {
                            let options = {
                                view: window,
                                bubbles: true,
                                cancelable: true,
                                ctrlKey: true,
                                button: 0
                            };

                            item.dispatchEvent(new MouseEvent('mousedown', options));
                            item.dispatchEvent(new MouseEvent('click', options));
                            item.dispatchEvent(new MouseEvent('mouseup', options));
                        }, delay);

                        delay += 500;
                    }
                });
            })();
        ]]

        evalcef(auto_js)
        wait(4000)
        closeInventory()
    end)
end

local function startDelPlayerWorker()
    if delplayer.worker then return end

    delplayer.worker = lua_thread.create(function()
        while delplayer.state.v do
            local myid = select(2, sampGetPlayerIdByCharHandle(playerPed))

            for _, handle in ipairs(getAllChars()) do
                if doesCharExist(handle) then
                    local _, id = sampGetPlayerIdByCharHandle(handle)
                    if id and id ~= myid then
                        emul_rpc('onPlayerStreamOut', { id })
                    end
                end
            end

            local cd = delplayer.cd.v
            if cd < 1 then cd = 1 end
            wait(cd * 1000)
        end

        delplayer.worker = nil
    end)
end

local function stopDelPlayerWorker()
    if delplayer.worker then
        delplayer.worker:terminate()
        delplayer.worker = nil
    end
end

local function removeStreamedCars()
    local myVeh = storeCarCharIsInNoSave(playerPed)

    for _, veh in ipairs(getAllVehicles()) do
        if doesVehicleExist(veh) and veh ~= myVeh then
            local _, carId = sampGetVehicleIdByCarHandle(veh)
            if carId then
                emul_rpc('onVehicleStreamOut', { carId })
            end
        end
    end
end

local function startDelCarWorker()
    if delcar.worker then return end

    delcar.worker = lua_thread.create(function()
        while delcar.state.v do
            removeStreamedCars()

            local cd = delcar.cd.v
            if cd < 1 then cd = 1 end
            wait(cd * 1000)
        end

        delcar.worker = nil
    end)
end

local function stopDelCarWorker()
    if delcar.worker then
        delcar.worker:terminate()
        delcar.worker = nil
    end
end

local function calcReconnectDelay()
    if arec.mode.v == 0 then
        return arec.wait.v
    else
        local min = arec.r_min.v
        local max = arec.r_max.v

        if min < 1 then min = 1 end
        if max < min then max = min end

        return math.random(min, max)
    end
end

function toggleTaxAuto()
    if tax.active then
        stopTaxWorker()
        tax.active = false
        AFKMessage('Àâòîîïëàòà íàëîãîâ îñòàíîâëåíà')
    else
        initTaxTimer()
        startTaxWorker()
        tax.active = true
        AFKMessage('Àâòîîïëàòà íàëîãîâ çàïóùåíà')
    end
end
local function calcNextTaxTs()
    local now = os.time()

    if tax.setmode.v == 0 then
        return now + tax.exact.v * 60
    else
        local min = tax.rand_min.v
        local max = tax.rand_max.v

        -- çàùèòà îò äîëáî¸áñêèõ çíà÷åíèé
        if min < 1 then min = 1 end
        if max < min then max = min end

        local r = math.random(min, max)
        return now + r * 60
    end
end
function initTaxTimer()
    tax.last_ts = os.time()
    tax.next_ts = calcNextTaxTs()
end
function startTaxWorker()
    if tax.worker then return end

    tax.worker = lua_thread.create(function()
        while true do
            wait(1000)

            if not tax.state or not tax.active then goto cont end
            if tax.running then goto cont end
            if tax.next_ts == 0 then goto cont end

            if os.time() >= tax.next_ts then
                tax.running = true
                startTaxPayment()
            end

            ::cont::
        end
    end)
end
function stopTaxWorker()
    if tax.worker then
        tax.worker:terminate()
        tax.worker = nil
    end

    tax.running = false
    tax.next_ts = 0
end
function startTaxPayment()
    AFKMessage('Àâòîîïëàòà íàëîãîâ: îòêðûâàþ òåëåôîí')
    tax.step = 1
    sampSendChat('/phone')
end
function launchBankApp()
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)

    local msg = "launchedApp|24"
    raknetBitStreamWriteInt16(bs, #msg)
    raknetBitStreamWriteString(bs, msg)

    raknetSendBitStreamEx(bs, 1, 7, 1)
    raknetDeleteBitStream(bs)
end

function acef.onArizonaDisplay(packet)
    if not acef.decode(packet) then return end

    if packet.event == "event.setActiveView" then
        local view = packet.json[1]
        if view == "Phone" and tax.running and tax.step == 1 then
            tax.step = 2
            AFKMessage('Òåëåôîí îòêðûò, çàïóñêàþ áàíê')
            launchBankApp()
        end
    end

    if packet.event == "event.phone.launchedApp" then
        local appId = packet.json[1]
        if dialogId == 6565 then
            tax.step = 3
            AFKMessage('Áàíê îòêðûò')
        end
    end
end

function handleTaxDialog(dialogId, style, dialogTitle, text)
    if not tax.running then return end

    local txt = text or ''
    local ttl = title or ''

    -- ÌÅÍÞ ÁÀÍÊÀ
    if dialogId == 6565 and tax.step == 2 then
        print('[AUTO TAX] Bank menu')
        sampSendDialogResponse(dialogId, 1, 4, '')
        tax.step = 4
        return true
    end

    -- ÏÎÄÒÂÅÐÆÄÅÍÈÅ
    if dialogId == 15252 then
        print('[AUTO TAX] Confirm taxes')
        sampSendDialogResponse(dialogId, 1, 0, '')
        finishTaxPayment(true)
        return true
    end
    if dialogTitle:find('Îïëàòà âñåõ íàëîãîâ') then
		sampSendDialogResponse(sampGetCurrentDialogId(), 0, -1, -1)
		sampCloseCurrentDialogWithButton(0)
		sampSendChat('/phone')
		finishTaxPayment(true)
	end
end

function finishTaxPayment(success)
    if success then
        AFKMessage('Àâòîîïëàòà íàëîãîâ: âûïîëíåíî')
        tax.last_ts = os.time()
        tax.next_ts = calcNextTaxTs()
    else
        AFKMessage('Àâòîîïëàòà íàëîãîâ: îøèáêà, ïîâòîð ÷åðåç 5 ìèíóò')
        tax.next_ts = os.time() + 5 * 60
    end

    tax.running = false
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
function requestRunner() -- ñîçäàíèå effil ïîòîêà ñ ôóíêöèåé https çàïðîñà
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
local vkerr, vkerrsend -- ñîîáùåíèå ñ òåêñòîì îøèáêè, nil åñëè âñå îê
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
			vkerr = 'Îøèáêà!\nÏðè÷èíà: Íåò ñîåäèíåíèÿ ñ VK!'
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
								sendvknotf('Êîìàíäû:\n!send - Îòïðàâèòü ñîîáùåíèå èç VK â Èãðó\n!getplstats - ïîëó÷èòü ñòàòèñòèêó ïåðñîíàæà\n!getplhun - ïîëó÷èòü ãîëîä ïåðñîíàæà\n!getplinfo - ïîëó÷èòü èíôîðìàöèþ î ïåðñîíàæå\n!sendcode - îòïðàâèòü êîä ñ ïî÷òû\n!sendvk - îòïðàâèòü êîä èç ÂÊ\n!gauth - îòïðàâèòü êîä èç GAuth\n!p/!h - ñáðîñèòü/ïðèíÿòü âûçîâ\n!d [ïóíêò èëè òåêñò] - îòâåòèòü íà äèàëîãîâîå îêíî\n!dc - çàêðûòü äèàëîã\n!screen - ñäåëàòü ñêðèíøîò (ÎÁßÇÀÒÅËÜÍÎ ÏÐÎ×ÈÒÀÒÜ !helpscreen)\n!helpscreen - ïîìîùü ïî êîìàíäå !screen\nÏîääåðæêà: @notify.arizona')
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
								sendvknotf('Âûêëþ÷àþ èãðó')
								wait(1000)
								os.execute("taskkill /f /im gta_sa.exe")
							elseif pl.button == 'offpc' then
								os.execute("shutdown -s -t 30")
								sendvknotf('Êîìïüþòåð áóäåò âûêëþ÷åí ÷åðåç 30 ñåêóíä.')
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
							sendvknotf('Ñîîáùåíèå "' .. args .. '" áûëî óñïåøíî îòïðàâëåíî â èãðó')
						else
							sendvknotf('Íåïðàâèëüíûé àðãóìåíò! Ïðèìåð: !send [ñòðîêà]')
						end
					elseif objsend[1] == '!sendcode' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampSendDialogResponse(8928, 1, false, (args))
							sendvknotf('Êîä "' .. args .. '" áûë óñïåøíî îòïðàâëåí â äèàëîã')
						else
							sendvknotf('Íåïðàâèëüíûé àðãóìåíò! Ïðèìåð: !sendcode [êîä]')
					end
					elseif objsend[1] == '!sendvk' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampSendDialogResponse(7782, 1, false, (args))
							sendvknotf('Êîä "' .. args .. '" áûë óñïåøíî îòïðàâëåí â äèàëîã')
						else
							sendvknotf('Íåïðàâèëüíûé àðãóìåíò! Ïðèìåð: !sendvk [êîä]')
					end
					elseif objsend[1] == '!gauth' then
						print('this')
						local args = table.concat(objsend, " ", 2, #objsend) 
						if #args > 0 then
							args = u8:decode(args)
							sampSendDialogResponse(8929, 1, false, (args))
							sendvknotf('Êîä "' .. args .. '" áûë óñïåøíî îòïðàâëåí â äèàëîã')
						else
							sendvknotf('Íåïðàâèëüíûé àðãóìåíò! Ïðèìåð: !gauth [êîä]')
					end
					elseif diasend:match('^!d ') then
						diasend = diasend:sub(1, diasend:len() - 1)
						local style = sampGetCurrentDialogType()
						if style == 2 or style > 3 and diasend:match('^!d (%d*)') then
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, tonumber(u8:decode(diasend:match('^!d (%d*)'))) - 1, -1)
						elseif style == 1 or style == 3 then
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, u8:decode(diasend:match('^!d (.*)')))
						else
							sampSendDialogResponse(sampGetCurrentDialogId(), 1, -1, -1) -- äà
						end
						closeDialog()
					elseif diasend:match('^!dc ') then
						sampSendDialogResponse(sampGetCurrentDialogId(), 0, -1, -1) -- íåò
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
				vkerr = 'Îøèáêà!\nÏðè÷èíà: Íåò ñîåäèíåíèÿ ñ VK!'
				return
			end
			local t = decodeJson(result)
			if t then
				if t.error then
					vkerr = 'Îøèáêà!\nÊîä: ' .. t.error.error_code .. ' Ïðè÷èíà: ' .. t.error.error_msg
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

function parseInfobarTemplate(template)

	template = u8:decode(template)

    local pid = select(2, sampGetPlayerIdByCharHandle(playerPed))
    local nick = sampGetPlayerNickname(pid)
    local server = sampGetCurrentServerName()

    local hp = math.floor(getCharHealth(playerPed))
    local armour = math.floor(getCharArmour(playerPed))

    local money = getPlayerMoney(PLAYER_HANDLE)

    local lvl = player_lvl or "?"

    local hunger = cefSatiety or "?"

    local vars = {
        nick = nick,
        id = pid,
        server = server,

        time = os.date("%H:%M:%S"),
        date = os.date("%d.%m.%Y"),

        money = money,
        lvl = lvl,
        hp = hp,
        armour = armour,
        hunger = hunger
    }

    template = template:gsub("{(.-)}", function(key)
        return vars[key] ~= nil and tostring(vars[key]) or "{"..key.."}"
    end)

    return template
end

function buildInfobar()

    if infobar.style.v == 3 then
        return parseInfobarTemplate(infobar.custom.v)
    end

    local host = sampGetCurrentServerName()
    local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) ..
        '[' .. select(2,sampGetPlayerIdByCharHandle(playerPed)) .. ']'

    return '[AFK Tools | Notifications | '..acc..' | '..host..']'
end

function applyInfobar(msg)

    local bar = buildInfobar()

    if infobar.style.v == 0 then
        return bar .. '\n' .. msg

    elseif infobar.style.v == 1 then
        return msg .. '\n' .. bar

    elseif infobar.style.v == 2 then
        return msg

    elseif infobar.style.v == 3 then

        if infobar.custom_pos.v == 0 then
            return bar .. '\n' .. msg

        elseif infobar.custom_pos.v == 1 then
            return msg .. '\n' .. bar

        else
            return msg
        end

    end
end

function getInfobarPreview()
    local bar = buildInfobar()
    if not bar or bar == "" then
        return ""
    end
    return bar
end

function sendvknotf(msg, host)
	host = host or sampGetCurrentServerName()
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
	msg = msg:gsub('{......}', '')
	msg = applyInfobar(msg)
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
				vkerrsend = 'Îøèáêà!\nÊîä: ' .. t.error.error_code .. ' Ïðè÷èíà: ' .. t.error.error_msg
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
				vkerrsend = 'Îøèáêà!\nÊîä: ' .. t.error.error_code .. ' Ïðè÷èíà: ' .. t.error.error_msg
				return
			end
			vkerrsend = nil
		end)
	end
end
function encodeUrl1(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end
function requestRunner2() -- ñîçäàíèå effil ïîòîêà ñ ôóíêöèåé https çàïðîñà
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
function threadHandle2(runner2, url2, args2, resolve2, reject2) -- îáðàáîòêà effil ïîòîêà áåç áëîêèðîâîê
	local t = runner2(url2, args2)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve2(result) else reject2(result) end
	elseif err then
		reject2(err)
	elseif status == 'canceled' then
		reject2(status)
	end
	t:cancel(0)
end

function async_http_request2(url2, args2, resolve2, reject2)
	local runner2 = requestRunner2()
	if not reject2 then reject2 = function() end end
	lua_thread.create(function()
		threadHandle2(runner2, url2, args2, resolve2, reject2)
	end)
end

function sendtgnotf(msg)
	if tgnotf.state.v then
	host = host or sampGetCurrentServerName()
	local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
    msg = msg:gsub('{......}', '')
    msg = applyInfobar(msg)
    msg = encodeUrl1(msg)
	async_http_request2('https://api.telegram.org/bot' .. tgnotf.token.v .. '/sendMessage?chat_id=' .. tgnotf.user_id.v .. '&reply_markup={"keyboard": [["Info", "Stats", "Hungry"], ["Enable auto-opening", "Last 10 lines of chat"], ["Send Dialogs", "Support"]], "resize_keyboard": true}&text='..msg,'', function(result) end)
	end
end

function getLastUpdate()
	if tgnotf.state.v then 
    async_http_request2('https://api.telegram.org/bot'..tgnotf.token.v..'/getUpdates?chat_id='..tgnotf.user_id.v..'&offset=-1','',function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table.ok then
                if #proc_table.result > 0 then
                    local res_table = proc_table.result[1]
                    if res_table then
                        updateid = res_table.update_id
                    end
                else
                    updateid = 1 
					end
                end
            end
        end)
    end
end

function get_telegram_updates()
	if tgnotf.state.v then 
    while not updateid do wait(1) end
    local runner2 = requestRunner2()
    local reject2 = function() end
    local args2 = ''
    while true do
        url2 = 'https://api.telegram.org/bot'..tgnotf.token.v..'/getUpdates?chat_id='..tgnotf.user_id.v..'&offset=-1' -- ñîçäàåì ññûëêó
        threadHandle2(runner2, url2, args2, processing_telegram_messages, reject2)
        wait(0)
		end
    end
end

function processing_telegram_messages(result)
    if result and tgnotf.state.v then
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
						user_idtg = res_table.message.from.id
						if user_idtg == tonumber(tgnotf.user_id.v) then 
                        if message_from_user and tgnotf.sellotvtg.v then
                            local text = u8:decode(message_from_user) .. ' ' 
							if text:match('^Info') then
                                getPlayerInfoTG()
							elseif text:match('^Stats') then
								getPlayerArzStatsTG()
							elseif text:match('^Hungry') then
								getPlayerArzHunTG()
							elseif text:match('^Last 10 lines of chat') then
								lastchatmessageTG(10, sendtgnotf)
							elseif text:match('^Send Dialogs') then
								sendDialogTG(sendtgnotf)
							elseif text:match('^Enable auto-opening') then
								openchestrulletTG(sendtgnotf)
							elseif text:match('^Support') then
								sendtgnotf('Êîìàíäû:\n!send - Îòïðàâèòü ñîîáùåíèå èç VK â Èãðó\n!getplstats - ïîëó÷èòü ñòàòèñòèêó ïåðñîíàæà\n!getplhun - ïîëó÷èòü ãîëîä ïåðñîíàæà\n!getplinfo - ïîëó÷èòü èíôîðìàöèþ î ïåðñîíàæå\n!sendcode - îòïðàâèòü êîä ñ ïî÷òû\n!sendvk - îòïðàâèòü êîä èç ÂÊ\n!gauth - îòïðàâèòü êîä èç GAuth\n!p/!h - ñáðîñèòü/ïðèíÿòü âûçîâ\n!d [ïóíêò èëè òåêñò] - îòâåòèòü íà äèàëîãîâîå îêíî\n!dc - çàêðûòü äèàëîã\n!screen - ñäåëàòü ñêðèíøîò (ÎÁßÇÀÒÅËÜÍÎ ÏÐÎ×ÈÒÀÒÜ !helpscreen)\n!helpscreen - ïîìîùü ïî êîìàíäå !screen\nÏîääåðæêà: vk.com/notify.arizona')
							elseif text:match('^!getplstats') then
								getPlayerArzStatsTG()
							elseif text:match('^!getplinfo') then
                                getPlayerInfoTG()
                            elseif text:match('^!getplhun') then
                                getPlayerArzHunTG()
                            elseif text:match('^!send') then
								text = text:sub(1, text:len() - 1):gsub('!send ','')
								sampProcessChatInput(text)
								sendtgnotf('Ñîîáùåíèå "' .. text .. '" áûëî óñïåøíî îòïðàâëåíî â èãðó')
							elseif text:match('^!sendcode') then
								text = text:sub(1, text:len() - 1):gsub('!sendcode ','')
								sampSendDialogResponse(8928, 1, false, (text))
								sendtgnotf('Êîä "' .. text .. '" áûë óñïåøíî îòïðàâëåí â äèàëîã')
							elseif text:match('^!sendvk') then
								text = text:sub(1, text:len() - 1):gsub('!sendvk ','')
								sampSendDialogResponse(7782, 1, false, (text))
								sendtgnotf('Êîä "' .. text .. '" áûë óñïåøíî îòïðàâëåí â äèàëîã')
							elseif text:match('^!gauth') then
								text = text:sub(1, text:len() - 1):gsub('!gauth ','')
								sampSendDialogResponse(8929, 1, false, (text))
								sendtgnotf('Êîä "' .. text .. '" áûë óñïåøíî îòïðàâëåí â äèàëîã')
							elseif text:match('^!screen') then
								sendScreenTg()
							end
						end
                        end
                    end
                end
            end
        end
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
				vkerrsend = 'Îøèáêà!\nÊîä: ' .. t.error.error_code .. ' Ïðè÷èíà: ' .. t.error.error_msg
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
				vkerrsend = 'Îøèáêà!\nÊîä: ' .. t.error.error_code .. ' Ïðè÷èíà: ' .. t.error.error_msg
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
				vkerrsend = 'Îøèáêà!\nÊîä: ' .. t.error.error_code .. ' Ïðè÷èíà: ' .. t.error.error_msg
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
function vkKeyboard() --ñîçäàåò êîíêðåòíóþ êëàâèàòóðó äëÿ áîòà VK, êàê ñäåëàòü äëÿ áîëåå îáùèõ ñëó÷àåâ ïîêà íå çàäóìûâàëñÿ
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
	row[1].action.label = 'Èíôîðìàöèÿ'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "getstats"}'
	row[2].action.label = 'Ñòàòèñòèêà'
	row[3] = {}
	row[3].action = {}
	row[3].color = 'positive'
	row[3].action.type = 'text'
	row[3].action.payload = '{"button": "gethun"}'
	row[3].action.label = 'Ãîëîä'
	keyboard.buttons[2] = {} -- âòîðàÿ ñòðîêà êíîïîê
	row = keyboard.buttons[2]
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "lastchat10"}'
	row[2].action.label = 'Ïîñëåäíèå 10 ñòðîê ñ ÷àòà'
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "openchest"}'
	row[1].action.label = aopen and 'Âûêëþ÷èòü àâòîîòêðûòèå' or 'Âêëþ÷èòü àâòîîòêðûòèå'
	keyboard.buttons[3] = {} -- âòîðàÿ ñòðîêà êíîïîê
	row = keyboard.buttons[3]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'positive'
	row[1].action.type = 'text'
	row[1].action.payload = '{"button": "activedia"}'
	row[1].action.label = activedia and 'Íå îòïðàâëÿòü äèàëîãè' or 'Îòïðàâëÿòü äèàëîãè'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "support"}'
	row[2].action.label = 'Ïîääåðæêà'
	keyboard.buttons[4] = {} -- âòîðàÿ ñòðîêà êíîïîê
	row = keyboard.buttons[4]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'primary'
	row[1].action.type = 'text'
    row[1].action.payload = '{"button": "offkey"}'
	row[1].action.label = 'Âûêëþ÷åíèå &#128163;'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'primary'
	row[2].action.type = 'text'
    row[2].action.payload = '{"button": "keyboardkey"}'
	row[2].action.label = 'Óïðàâëåíèå &#9000;'
	keyboard.buttons[5] = {} -- âòîðàÿ ñòðîêà êíîïîê
	row = keyboard.buttons[5]
	row[1] = {}
	row[1].action = {}
	row[1].color = 'primary'
	row[1].action.type = 'text'
    row[1].action.payload = '{"button": "screenkey"}'
	row[1].action.label = 'Ñêðèíøîò'
	return encodeJson(keyboard)
end
function sendkeyboradkey()
	vkKeyboard2()
	sendvknotfv2('Êëàâèøè óïðàâëåíèÿ èãðîé')
end
function vkKeyboard2() --ñîçäàåò êîíêðåòíóþ êëàâèàòóðó äëÿ áîòà VK, êàê ñäåëàòü äëÿ áîëåå îáùèõ ñëó÷àåâ ïîêà íå çàäóìûâàëñÿ
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
	keyboard.buttons[2] = {} -- âòîðàÿ ñòðîêà êíîïîê
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
	sendoffpcgame('×òî âû õîòèòå âûêëþ÷èòü?')
end
function sendphonecall()
	phonekey()
	sendphonekey('Âàì çâîíÿò! Âûáåðèòå äåéñòâèå.')
end
function offboard() --ñîçäàåò êîíêðåòíóþ êëàâèàòóðó äëÿ áîòà VK, êàê ñäåëàòü äëÿ áîëåå îáùèõ ñëó÷àåâ ïîêà íå çàäóìûâàëñÿ
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
	row[1].action.label = 'Êîìïüþòåð'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "offgame"}'
	row[2].action.label = 'Çàêðûòü èãðó'
	return encodeJson(keyboard)
end
function phonekey() --ñîçäàåò êîíêðåòíóþ êëàâèàòóðó äëÿ áîòà VK, êàê ñäåëàòü äëÿ áîëåå îáùèõ ñëó÷àåâ ïîêà íå çàäóìûâàëñÿ
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
	row[1].action.label = 'Îòêëîíèòü'
	row[2] = {}
	row[2].action = {}
	row[2].color = 'positive'
	row[2].action.type = 'text'
	row[2].action.payload = '{"button": "phoneup"}'
	row[2].action.label = 'Ïðèíÿòü'
	return encodeJson(keyboard)
end
function dialogkey() --ñîçäàåò êîíêðåòíóþ êëàâèàòóðó äëÿ áîòà VK, êàê ñäåëàòü äëÿ áîëåå îáùèõ ñëó÷àåâ ïîêà íå çàäóìûâàëñÿ
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
		sendvknotf('Âû íå ïîäêëþ÷åíû ê ñåðâåðó!')
	end
end

function getPlayerInfoTG()
	if isSampLoaded() and isSampAvailable() and sampGetGamestate() == 3 then
		local response = ''
		response = response .. 'HP: ' .. getCharHealth(PLAYER_PED) .. '\n'
		response = response .. 'Armor: ' .. getCharArmour(PLAYER_PED) .. '\n'
		response = response .. 'Money: ' .. getPlayerMoney(PLAYER_HANDLE) .. '\n'
		response = response .. 'Online: ' .. getOnline() .. '\n'
		local x, y, z = getCharCoordinates(PLAYER_PED)
		response = response .. 'Coords: X: ' .. math.floor(x) .. ' | Y: ' .. math.floor(y) .. ' | Z: ' .. math.floor(z)
		sendtgnotf(response)
	else
		sendtgnotf('Âû íå ïîäêëþ÷åíû ê ñåðâåðó!')
	end
end

function getPlayerArzStatsTG()
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
		sendtgnotf(sendstatsstate == true and 'Îøèáêà! Â òå÷åíèè 10 ñåêóíä ñêðèïò íå ïîëó÷èë èíôîðìàöèþ!' or tostring(sendstatsstate))
		sendstatsstate = false
	else
		sendtgnotf('(Error) Ïåðñîíàæ íå çàñïàâíåí')
	end
end

function getPlayerArzHunTG()
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
		sendtgnotf(gethunstate == true and 'Îøèáêà! Â òå÷åíèè 10 ñåêóíä ñêðèïò íå ïîëó÷èë èíôîðìàöèþ!' or tostring(gethunstate))
		gethunstate = false
	else
		sendtgnotf('(Error) Ïåðñîíàæ íå çàñïàâíåí')
	end
end

function lastchatmessageTG(intchat, tochat)
	if sampIsLocalPlayerSpawned() then
		print('use: lastchat')
		local allchat = '\n'
		for i = 100-intchat, 99 do
			local getstr = select(1,sampGetChatString(i))
			allchat = allchat .. getstr .. '\n'
		end
		sendtgnotf(allchat)
	else
		sendtgnotf('(Error) Ïåðñîíàæ íå çàñïàâíåí')
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
		if not vknotf.dienable.v then sendvknotf(sendstatsstate == true and 'Îøèáêà! Â òå÷åíèè 10 ñåêóíä ñêðèïò íå ïîëó÷èë èíôîðìàöèþ!' or tostring(sendstatsstate)) end
		sendstatsstate = false
	else
		sendvknotf('(Error) Ïåðñîíàæ íå çàñïàâíåí')
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
		sendvknotf('(Error) Ïåðñîíàæ íå çàñïàâíåí')
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
		if not vknotf.dienable.v then sendvknotf(gethunstate == true and 'Îøèáêà! Â òå÷åíèè 10 ñåêóíä ñêðèïò íå ïîëó÷èë èíôîðìàöèþ!' or tostring(gethunstate)) end
		gethunstate = false
	else
		sendvknotf('(Error) Ïåðñîíàæ íå çàñïàâíåí')
	end
end
function randomInt() 
    math.randomseed(os.time() + os.clock())
    return math.random(-2147483648, 2147483648)
end 
function sendhelpscreen()
	sendvknotf('Èíñòðóêöèÿ ïî íàëàäêå êîìàíäû "!screen":\n\nÊîìàíäà !screen ðàáîòàåò ñëåäóþùèì îáðàçîì:\n Åñëè èãðà ñâ¸ðíóòà - ïðîèçîéäåò êðàø ñêðèïòà\n Åñëè èãðà íà âåñü ýêðàí - ïðèä¸ò ïðîñòî áåëûé ñêðèíøîò.\n ×òîáû ñðàáîòàëî èäåàëüíî - íóæíî ñäåëàòü èãðó â îêîííûé ðåæèì è ðàñòÿíóòü íà âåñü ýêðàí (íà ëàóí÷åðå ìîæíî ïðîñòî â íàñòðîéêàõ ëàóí÷åðà âêëþ÷èòü îêîííûé ðåæèì).\n Äëÿ ðàáîòû êîìàíäû íóæíî ñêà÷àòü íåîáõîäèìûå áèáëèîòåêè (ñêà÷àòü ìîæíî â ìåíþ VK/TG Notifications)')
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
        sendPhoto(getGameDirectory()..'/1.png') -- îòïðàâêà ôîòêè ïîñëå ñêðèíà
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
    os.remove(getGameDirectory()..'/1.png') -- Óäàëåíèå ôîòêè ñ ãëàç äîëîé 
    return requests.post(("https://api.vk.com/method/messages.send?peer_id=%d&attachment=%s&access_token=%s&random_id=%d&v=5.131"):format(vknotf.user_id.v, att_image, vknotf.token.v, randomInt()))
	end
end

function sendScreenTg()
	if tgnotf.state.v then 
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
        sendPhotoTg() -- îòïðàâêà ôîòêè ïîñëå ñêðèíà
		end
	end
end

function sendPhotoTg()
	lua_thread.create(function ()
            local result, response = telegramRequest(
                'POST', --[[ https://en.wikipedia.org/wiki/POST_(HTTP) ]]--
                'sendPhoto', --[[ https://core.telegram.org/bots/api#sendphoto ]]--
                { --[[ Àðãóìåíòû, ñì. https://core.telegram.org/bots/api#sendphoto ]]--
                    ['chat_id']    = tgnotf.user_id.v,  --[[ chat_id ]]--
                },
                { --[[ Ñàì ôàéë, ñþäà ìîæíî ïåðåäàâàòü êàê PATH(Ïóòü ê ôàéëó), òàê è FILE_ID(Ñì. https://core.telegram.org/bots/) ]]--
                    ['photo'] = string.format(getGameDirectory()..'/1.png') --[[ èëè æå ==getWorkingDirectory() .. '\\smirk.png'== ]]--
                },
                tgnotf.token.v --[[ Òîêåí Áîòà ]]
            )
	end)
end
function sendkeyALT()
	setVirtualKeyDown(18, true)
	setVirtualKeyDown(18, false)
end
function sendkeyESC()
	sampSendClickTextdraw(65535)
end
function setKeyFromVK(getkey)
	if isSampLoaded() and isSampAvailable() and sampIsLocalPlayerSpawned() then
		sendvknotf('Îòïðàâëåíî íàæàòèå íà êëàâèøó '..getkey)
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
		sendvknotf('Âàø ïåðñîíàæ íå çàñïàâíåí!')
	end
end
function telegramRequest(requestMethod, telegramMethod, requestParameters, requestFile, botToken, debugMode)
	local multipart = require('multipart-post')
	local dkjson    = require('dkjson')
    --[[ Arguments Part ]]--
    --[[ Argument #1 (requestMethod) ]]--
    local requestMethod = requestMethod or 'POST'
    if (type(requestMethod) ~= 'string') then
        error('[MoonGram Error] In Function "telegramRequest", Argument #1(requestMethod) Must Be String.')
    end
    if (requestMethod ~= 'POST' and requestMethod ~= 'GET' and requestMethod ~= 'PUT' and requestMethod ~= 'DETELE') then
        error('[MoonGram Error] In Function "telegramRequest", Argument #1(requestMethod) Dont Have "%s" Request Method.', tostring(requestMethod))
    end
    --[[ Argument #2 (telegramMethod) ]]--
    local telegramMethod = telegramMethod or nil
    if (type(requestMethod) ~= 'string') then
        error('[MoonGram Error] In Function "telegramRequest", Argument #2(telegramMethod) Must Be String.\nCheck: https://core.telegram.org/bots/api')
    end
    --[[ Argument #3 (requestParameters) ]]--
    local requestParameters = requestParameters or {}
    if (type(requestParameters) ~= 'table') then
        error('[MoonGram Error] In Function "telegramRequest", Argument #3(requestParameters) Must Be Table.')
    end
    for key, value in ipairs(requestParameters) do
        if (#requestParameters ~= 0) then
            requestParameters[key] = tostring(value)
        else
            requestParameters = {''}
        end
    end
    --[[ Argument #4 (botToken) ]]--
    local botToken = botToken or nil
    if (type(botToken) ~= 'string') then
        error('[MoonGram Error] In Function "telegramRequest", Argument #4(botToken) Must Be String.')
    end
    --[[ Argument #5 (debugMode) ]]--
    local debugMode = debugMode or false
    if (type(debugMode) ~= 'boolean') then
        error('[MoonGram Error] In Function "telegramRequest", Argument #5(debugMode) Must Be Boolean.')
    end

    if (requestFile and next(requestFile) ~= nil) then
        local fileType, fileName = next(requestFile)
        local file = io.open(fileName, 'rb')
        if (file) then
            lua_thread.create(function ()
                requestParameters[fileType] = {
                    filename = fileName,
                    data = file:read('*a')
                }
            end)
            file:close()
        else
            requestParameters[file_type] = fileName
        end
    end

    local requestData = {
        ['method'] = tostring(requestMethod),
        ['url']    = string.format('https://api.telegram.org/bot%s/%s', tostring(botToken), tostring(telegramMethod))
    }

    local body, boundary = multipart.encode(requestParameters)

    --[[ Request Part ]]--
    local thread = effil.thread(function (requestData, body, boundary)
        local response = {}

        --[[ Include Libraries ]]--
        local channel_library_requests = require('ssl.https')
        local channel_library_ltn12    = require('ltn12')

        --[[ Manipulations ]]--
        local _, source = pcall(channel_library_ltn12.source.string, body)
        local _, sink   = pcall(channel_library_ltn12.sink.table, response)

        --[[ Request ]]--
        local result, _ = pcall(channel_library_requests.request, {
                ['url']     = requestData['url'],
                ['method']  = requestData['method'],
                ['headers'] = {
                    ['Accept']          = '*/*',
                    ['Accept-Encoding'] = 'gzip, deflate',
                    ['Accept-Language'] = 'en-us',
                    ['Content-Type']    = string.format('multipart/form-data; boundary=%s', tostring(boundary)),
                    ['Content-Length']  = #body
                },
                ['source']  = source,
                ['sink']    = sink
        })
        if (result) then
            return { true, response }
        else
            return { false, response }
        end
    end)(requestData, body, boundary)

    local result = thread:get(0)
    while (not result) do
        result = thread:get(0)
        wait(0)
    end
    --[[ Running || Paused || Canceled || Completed || Failed ]]--
    local status, error = thread:status()
    if (not error) then
        if (status == 'completed') then
            local response = dkjson.decode(result[2][1])
            --[[ result[1] = boolean ]]--
            if (result[1]) then
                return true, response
            else
                return false, response
            end
        elseif (status ~= 'running' and status ~= 'completed') then
            return false, string.format('[TelegramLibrary] Error; Effil Thread Status was: %s', tostring(status))
        end
    else
        return false, error
    end
    thread:cancel(0)
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
			sendvknotf('Àâòîîòêðûòèå '..(aopen and 'âêëþ÷åíî!' or 'âûêëþ÷åíî!'))
		else
			sendvknotf("Âêëþ÷èòå ñóíäóê ñ ðóëåòêàìè!")
		end
	else
		sendvknotf('Âàø ïåðñîíàæ íå çàñïàâíåí!')
	end
end
function openchestrulletTG()
	if isSampLoaded() and isSampAvailable() and sampIsLocalPlayerSpawned() then
		if roulette.standart.v or roulette.donate.v or roulette.platina.v or roulette.mask.v or roulette.tainik.v then
			aopen = not aopen
			if aopen then 
				checkrulopen:run()
				afksets.v = false
			else 
				lua_thread.terminate(checkrulopen) 
			end
			sendtgnotf('Àâòîîòêðûòèå '..(aopen and 'âêëþ÷åíî!' or 'âûêëþ÷åíî!'))
		else
			sendtgnotf("Âêëþ÷èòå ñóíäóê ñ ðóëåòêàìè!")
		end
	else
		sendtgnotf('Âàø ïåðñîíàæ íå çàñïàâíåí!')
	end
end
function sendDialog()
	activedia = not activedia
	if activedia then 
	vknotf.dienable.v = true
	sendvknotf('Îòïðàâêà äèàëîãîâ â VK âêëþ÷åíà.')
	else
	vknotf.dienable.v = false
	sendvknotf('Îòïðàâêà äèàëîãîâ â VK îòêëþ÷åíà.')
	end
end
function sendDialogTG()
	activedia = not activedia
	if activedia then 
	tgnotf.dienable.v = true
	sendtgnotf('Îòïðàâêà äèàëîãîâ â TG âêëþ÷åíà.')
	else
	tgnotf.dienable.v = false
	sendtgnotf('Îòïðàâêà äèàëîãîâ â TG îòêëþ÷åíà.')
	end
end
function openchestrullet()
	if sampIsLocalPlayerSpawned() then
		if roulette.standart.v or roulette.donate.v or roulette.platina.v or roulette.mask.v or roulette.tainik.v then
			aopen = not aopen
			AFKMessage('Àâòîîòêðûòèå '..(aopen and 'âêëþ÷åíî!' or 'âûêëþ÷åíî!'))
			if aopen then 
				checkrulopen:run()
				afksets.v = false
			else 
				lua_thread.terminate(checkrulopen) 
			end
		else
			AFKMessage("Âêëþ÷èòå ñóíäóê ñ ðóëåòêàìè!")
		end
	else
		AFKMessage("Âàø ïåðñîíàæ íå çàñïàâíåí!")
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
		url = server .. '?act=a_check&key=' .. key .. '&ts=' .. ts .. '&wait=25' --ìåíÿåì url êàæäûé íîâûé çàïðîñ ïîòîêa, òàê êàê server/key/ts ìîãóò èçìåíÿòüñÿ
		threadHandle(runner, url, args, longpollResolve, reject)
		wait(100)
	end
end
function bizpiar()
	while true do wait(0)
		if bizpiaron then
			sampProcessChatInput(u8:decode(piar.piar1.v))
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
				sampProcessChatInput(u8:decode(piar.piar2.v))
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
				sampProcessChatInput(u8:decode(piar.piar3.v))
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

function libs()
	downloadUrlToFile('https://github.com/SMamashin/AFKTools/raw/main/resource/fonts/fontawesome-webfont.ttf',
	'moonloader\\resource\\AFKTools\\Fonts\\fontawesome-webfont.ttf', 
	'fontawesome-webfont.ttf')
	
	downloadUrlToFile('https://github.com/SMamashin/AFKTools/raw/main/resource/AFKTools/script_banner.png',
	'moonloader\\resource\\AFKTools\\script_banner.png', 
	'script_banner.png')

end
 

function main()
    while not isSampAvailable() do
        wait(0)
	end
	libs()
	getLastUpdate()
	if piar.auto_piar.v and (os.time() - piar.last_time) <= piar.auto_piar_kd.v then
		lua_thread.create(function()
			while not sampIsLocalPlayerSpawned() do wait(0) end
			bizpiaron = true
			activatePiar(bizpiaron)
			AFKMessage('[ÀâòîÏèàð] Ïèàð âêëþ÷åí ò.ê ïðîøëî ìåíüøå ÷åì '..piar.auto_piar_kd.v..' ñåêóíä ïîñëå ïîñëåäíåé âûãðóçêè')
		end)
	end
	local _a = [[Ñêðèïò óñïåøíî çàïóùåí!
Âåðñèÿ: %s
Îòêðûòü ìåíþ: /afktools
Àâòîðû: Bakhusse & Mamashin.]]
	if autoupdateState.v then
		updates:autoupdate()
	else
		updates:getlast()
	end
	AFKMessage(_a:format(thisScript().version))
	if vknotf.iscrashscript.v then
		sendvknotf('Ñêðèïò îæèë!')
	end	
	if tgnotf.iscrashscript.v then
		sendtgnotf('Ñêðèïò îæèë!')
	end
	sampRegisterChatCommand('eattest',function() gotoeatinhouse = true; sampSendChat('/home') end)
	sampRegisterChatCommand('afktools',function() afksets.v = not afksets.v end)
	sampRegisterChatCommand('afkreload',function() thisScript():reload() end)
	sampRegisterChatCommand('afkunload',function() thisScript():unload() end)
	sampRegisterChatCommand('autorul', function()
		if aoc.setmode.v == 0 then
			openchestrullet()
		end
		if aoc.setmode.v == 1 then
			newaoc()
		end
	end)
	sampRegisterChatCommand('afkkick', closeConnect)
	sampRegisterChatCommand('afksrec', function() 
		if handle_aurc then
			handle_aurc:terminate()
			handle_aurc = nil
			AFKMessage('Àâòîðåêîííåêò îñòàíîâëåí!')
		else
			AFKMessage('Âû ñåé÷àñ íå îæèäàåòå àâòîðåêîííåêòà!')
		end
		if handle_rc then
			handle_rc:terminate()
			handle_rc = nil
			AFKMessage('Ðåêîííåêò îñòàíîâëåí!')
		else
			AFKMessage('Âû ñåé÷àñ íå îæèäàåòå ðåêîííåêòà!')
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
	lua_thread.create(get_telegram_updates)
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

--// Êðóòåöêèå îòñòóïû íà 5 //--

function stepace5()
	for i = 1, 5 do

	imgui.Spacing()

	end

end

--ðåíäåð óâåäîâ
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
				notfList.pos = imgui.ImVec2(notfList.pos.x, (notfList.pos.y - (count == 1 and notfList.size.y or (notfList.size.y + 60))))
				imgui.SetNextWindowPos(notfList.pos, _, imgui.ImVec2(0.0, 0.0))
				imgui.SetNextWindowSize(imgui.ImVec2(200, notfList.size.y + imgui.GetStyle().ItemSpacing.y + imgui.GetStyle().WindowPadding.y+45))
				imgui.Begin(u8'##msg' .. k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
				imgui.RenderMsgLogo() imgui.SameLine() imgui.CenterText("AFK Tools")
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
--imgui: ýëåìåíòû àêêîâ
function autofillelementsaccs()
	if imgui.Button(u8('Âðåìåííûå äàííûå')) then menufill = 1 end
	imgui.SameLine()
	if imgui.Button(u8('Äîáàâèòü àêêàóíò')) then
		imgui.OpenPopup('##addacc')
	end
	if imgui.BeginPopupModal('##addacc',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.CenterText(u8('Äîáàâèòü íîâûé àêêàóíò'))
		imgui.Separator()
		imgui.CenterText(u8('Íèê'))
		imgui.Separator()
		imgui.InputText('##nameadd',addnew.name)
		imgui.Separator()
		imgui.CenterText(u8('Ïàðîëü'))
		imgui.Separator()
		imgui.InputText('##addpas',addnew.pass)
		imgui.Separator()
		imgui.CenterText(u8('ID Äèàëîãà'))
		imgui.SameLine()
		imgui.TextQuestion(u8('ID Äèàëîãà â êîòîðûé íàäî ââåñòè ïàðîëü\nÍåñêîëüêî ID äëÿ Arizona RP\n	2 - Äèàëîã ââîäà ïàðîëÿ\n	991 - Äèàëîã PIN-Êîäà áàíêà'))
		imgui.Separator()
		imgui.InputInt('##dialogudadd',addnew.dialogid)
		imgui.Separator()
		imgui.CenterText(u8('IP ñåðâåðà'))
		imgui.SameLine()
		imgui.TextQuestion(u8('IP Ñåðâåðà, íà êîòîðîì áóäåò ââåäåí ïàðîëü\nÏðèìåð: 185.169.134.171:7777'))
		imgui.Separator()
		imgui.InputText('##ipport',addnew.serverip)
		imgui.Separator()
		if imgui.Button(u8("Äîáàâèòü"), imgui.ImVec2(-1, 20)) then
			if addnew:save() then
				imgui.CloseCurrentPopup()
			end
		end
		if imgui.Button(u8("Çàêðûòü"), imgui.ImVec2(-1, 20)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	imgui.SameLine()
	imgui.Checkbox(u8('Âêëþ÷èòü'),autologin.state); imgui.SameLine(); imgui.TextQuestion(u8('Âêëþ÷àåò àâòîçàïîëíåíèå â äèàëîãè'))
	imgui.SameLine()
	imgui.CenterText(u8'Àâòîçàïîëíåíèå ' .. fa.ICON_PENCIL_SQUARE); imgui.SameLine()
	imgui.SameLine(838)
	if imgui.Button(u8('Îáíîâèòü')) then
		local f = io.open(file_accs, "r")
		if f then
			savepass = decodeJson(f:read("a*"))
			f:close()
		end
		AFKMessage('Ïîäãðóæåííû íîâûå äàííûå')
	end
	imgui.Columns(3, _, true)
	imgui.Separator()
	imgui.SetColumnWidth(-1, 150); imgui.Text(u8"   Íèêíåéì"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 150); imgui.Text(u8"Ñåðâåð"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 450); imgui.Text(u8"Ïàðîëè"); imgui.NextColumn()
	for k, v in pairs(savepass) do
		imgui.Separator()
		if imgui.Selectable(u8('   '..v[1]..'##'..k), false, imgui.SelectableFlags.SpanAllColumns) then imgui.OpenPopup('##acc'..k) end
		if imgui.BeginPopupModal('##acc'..k,true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			btnWidth2 = (imgui.GetWindowWidth() - 22)/2
			imgui.CreatePaddingY(8)
			imgui.CenterText(u8('Àêêàóíò '..v[1]))
			imgui.Separator()
			for f,t in pairs(v[3]) do
				imgui.Text(u8('Äèàëîã[ID]: '..v[3][f].id..' Ââåä¸ííûå äàííûå: '..v[3][f].text))
				if editpass.numedit == f then
					imgui.PushItemWidth(-1)
					imgui.InputText(u8'##pass'..f,editpass.input)
					imgui.PopItemWidth()
					if imgui.Button(u8("Ïîäòâåðäèòü##"..f), imgui.ImVec2(-1, 20)) then
						v[3][f].text = editpass.input.v
						editpass.input.v = ''
						editpass.numedit = -1
						saveaccounts()
					end
				elseif editpass.numedit == -1 then
					if imgui.Button(u8("Ñìåíèòü ïàðîëü##2"..f), imgui.ImVec2(-1, 20)) then
						editpass.input.v = v[3][f].text
						editpass.numedit = f
					end
				end
				if imgui.Button(u8("Ñêîïèðîâàòü##"..f), imgui.ImVec2(btnWidth2, 0)) then
					setClipboardText(v[3][f].text)
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if imgui.Button(u8("Óäàëèòü##"..f), imgui.ImVec2(btnWidth2, 0)) then
					v[3][f] = nil
					if #v[3] == 0 then
						savepass[k] = nil
					end
					saveaccounts()
				end
				imgui.Separator()
			end
			if imgui.Button(u8("Ïîäêëþ÷èòüñÿ"), imgui.ImVec2(-1, 20)) then
				local ip2, port2 = string.match(v[2], "(.+)%:(%d+)")
				reconname(v[1],ip2, tonumber(port2))
			end
			if imgui.Button(u8("Óäàëèòü âñå äàííûå"), imgui.ImVec2(-1, 20)) then
				savepass[k] = nil
				imgui.CloseCurrentPopup()
				saveaccounts()
			end
			if imgui.Button(u8("Çàêðûòü##sdosodosdosd"), imgui.ImVec2(-1, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.CreatePaddingY(8)
			imgui.EndPopup()
		end
		imgui.NextColumn()
		imgui.Text(tostring(v[2]))
		imgui.NextColumn()
		imgui.Text(u8('Êîë-âî ïàðîëåé: '..#v[3]..'. Íàæìèòå ËÊÌ äëÿ óïðàâëåíèÿ ïàðîëÿìè'))
		imgui.NextColumn()
	end
	imgui.Columns(1)
	imgui.Separator()
end
--imgui: ýëåìåíòû ñåéâà
function autofillelementssave()
	if imgui.Button(u8'< Àêêàóíòû') then menufill = 0 end
	imgui.SameLine()
	imgui.CenterText(u8'Àâòîçàïîëíåíèå')
	imgui.SameLine(838) 
	if imgui.Button(u8('Î÷èñòêà')) then temppass = {}; AFKMessage('Áóôåð âðåìåííûõ ïàðîëåé î÷èùåí!') end
	imgui.Columns(5, _, true)
	imgui.Separator()--710
	imgui.SetColumnWidth(-1, 130); imgui.Text(u8"Äèàëîã[ID]"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 150); imgui.Text(u8"Íèêíåéì"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 140); imgui.Text(u8"Ñåðâåð"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 170); imgui.Text(u8"Ââåäåííûå äàííûå"); imgui.NextColumn()
	imgui.SetColumnWidth(-1, 140); imgui.Text(u8"Âðåìÿ"); imgui.NextColumn()
	for k, v in pairs(temppass) do
		if imgui.Selectable('   '..tostring(u8(string.gsub(v.title, "%{.*%}", "") .. "[" .. v.id .. "]")) .. "##" .. k, false, imgui.SelectableFlags.SpanAllColumns) then
			saveacc(k)
			saveaccounts()
			AFKMessage('Ïàðîëü '..v.text..' äëÿ àêêàóíòà '..v.nick..' íà ñåðâåðå '..v.ip..' ñîõðàí¸í!')
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

-- Øðèôò v4(êðèíæ ïèçäåö) -- 

function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/AFKTools/fonts/fontawesome-webfont.ttf', 15, font_config, fa_glyph_ranges)

    end
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function imgui.OnDrawFrame()
	if afksets.v then
		local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed)))
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
		-- imgui.SetCursorPosX(350) -- ïîçâîëÿåò çàäàòü ïîëîæåíèå ôóíêöèè ïî ãîðèçíîòàëè
		-- imgui.SetCursorPosY(85) -- ïîçâîëÿåò çàäàòü ïîëîæåíèå ôóíêöèè ïî âåðòèêàëè
		local hostserver = sampGetCurrentServerName()
		imgui.SetCursorPos(imgui.ImVec2(40,8)) -- Author: neverlane(ronnyevans)\n
		imgui.RenderLogo() imgui.SameLine() imgui.Text(u8('\nDev/Support: Bakhusse & Mamashin\nÀêêàóíò: ' ..acc))
		imgui.SetCursorPos(imgui.ImVec2(516,8))
		imgui.BeginGroup()
		imgui.Text(u8('Âåðñèÿ -> Òåêóùàÿ: '..thisScript().version..' | Àêòóàëüíàÿ: '..(updates.data.result and updates.data.relevant_version or 'Error')))
		if imgui.Button(u8('Ïðîâåðèòü îáíîâëåíèå'),imgui.ImVec2(150,20)) then
			updates:getlast()
		end
		imgui.SameLine()
		local renderdownloadupd = (updates.data.result and updates.data.relevant_version ~= thisScript().version) and imgui.Button or imgui.ButtonDisabled
		if renderdownloadupd(u8('Çàãðóçèòü îáíîâëåíèå'),imgui.ImVec2(150,20)) then
			if updates.data.result and updates.data.relevant_version ~= thisScript().version then
				updates:download()
			end
		end
		imgui.EndGroup()
		imgui.SetCursorPos(imgui.ImVec2(880,25))
		imgui.CloseButton(6.5)
		imgui.SetCursorPos(imgui.ImVec2(0,60))
		imgui.Separator()

		-- Buttons on main menu script -- 


		if menunum == 0 then
			local buttons = {
				{fa.ICON_USER .. u8(' Îñíîâíîå'),1,u8('Íàñòðîéêà îñíîâíûõ ôóíêöèé')},
				{fa.ICON_PENCIL_SQUARE .. u8(' Àâòîçàïîëíåíèå'),2,u8('Àâòîââîä òåêñòà â äèàëîãè')},
				{fa.ICON_CUTLERY .. u8(' Àâòî-åäà'),3,u8('Àâòî-åäà & Àâòî-õèëë')},
				{fa.ICON_INFO .. u8(' Èíôîðìàöèÿ'),4,u8('Ïîëåçíàÿ èíôîðìàöèÿ î ïðîåêòå')},
				{fa.ICON_HISTORY .. u8(' Èñòîðèÿ îáíîâëåíèé'),5,u8('Ñïèñîê èçìåíåíèé êîòîðûå\n	 ïðîèçîøëè â ñêðèïòå')},
				{fa.ICON_COGS .. u8(' Êàñòîìèçàöèÿ'),6,u8('     Âûáîð ñòèëÿ, èçìåíåíèå òåìû\nñêðèïòà, èíôîáàðà â óâåäîìëåíèÿõ')},
				{fa.ICON_SEARCH .. u8(' Ïîèñê â ÷àòå'),7,u8('Îòïðàâëÿåò íóæíûå ñîîáùåíèÿ \n                  ñ ÷àòà â ') .. fa.ICON_VK .. u8(' è ') .. fa.ICON_TELEGRAM},
				{fa.ICON_VK .. u8(' Notifications'),8,u8('Óâåäîìëåíèÿ â ÂÊîíòàêòå')},
				{fa.ICON_TELEGRAM .. u8(' Notifications'),9,u8('Óâåäîìëåíèÿ â Telegram')}
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
			if imgui.Button(u8('Ñîõðàíèòü íàñòðîéêè'),imgui.ImVec2(150,30)) then saveini() end
			imgui.SameLine()
			if imgui.Button(u8('Ïåðåçàãðóçèòü ñêðèïò'),imgui.ImVec2(150,30)) then thisScript():reload() end
			imgui.EndGroup()
		
		-- Ðàçäåë îñíîâíûõ íàñòðîåê -- 	

		elseif menunum == 1 then
			welcomeText = not imgui.TextColoredRGB("") 
			PaddingSpace()
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.Separator()
			imgui.CenterText(u8('Àâòîðåêîííåêò'))
			imgui.Separator()
			PaddingSpace()
			imgui.Checkbox(u8('Âêëþ÷èòü àâòîðåêîííåêò'), arec.state)
			if arec.state.v then
				imgui.Checkbox(u8('Âêëþ÷èòü àâòîðåêîííåêò ïðè You are banned from this server'), arec.statebanned)
			    imgui.PushItemWidth(160)
			    imgui.Text(u8'Ðåæèì çàäåðæêè')
			    imgui.Combo('##arec.mode', arec.mode, arecmode, -1)
			    imgui.PushItemWidth(100)
				if arec.mode.v == 0 then
			        imgui.InputInt(u8'Çàäåðæêà (ñåê)', arec.wait, 0)
			    else
			        imgui.InputInt(u8'Îò (ñåê)', arec.r_min, 1)
			        imgui.SameLine()
			        imgui.InputInt(u8'Äî (ñåê)', arec.r_max, 1)
			    end
			    imgui.PopItemWidth()
			end
			PaddingSpace()
			imgui.Separator()
			imgui.CenterText(u8('Àâòîîïëàòà íàëîãîâ (for ADD VIP)'))
			imgui.Separator()
			PaddingSpace()
			imgui.Checkbox(u8('Âêëþ÷èòü àâòîîïëàòó íàëîãîâ'), tax.state)
			if tax.state.v then
				imgui.Text(u8'Ðåæèì ðàáîòû')
        	    imgui.PushItemWidth(120)
        	    imgui.Combo('##tax.mode', tax.setmode, taxmode, -1); imgui.SameLine() imgui.TextQuestion(u8('Òî÷íîå ÊÄ - Òî÷íûé ïðîìåæóòîê âðåìåíè îïëàòû íàëîãîâ (ëåãêî ïàëèòñÿ â ëîãàõ)\nÏðèìåðíîå ÊÄ - Ðàíäîìíûé ïðîìåæóòîê âðåìåíè îïëàòû íàëîãîâ, íóæíî óêàçàòü ìèíèìàëüíîå è ìàêñèìàëüíîå êîëè÷åñòâî ìèíóò. Ïðèìåð: Ïðè óêàçàíèè 100-120 ìèíóò ñêðèïò ñàì ðàíäîìíûì îáðàçîì âûáåðåò êîëè÷åñòâî ìèíóò (íàïðèìåð, 114) è ÷åðåç ýòî âðåìÿ îïëàòèò íàëîãè.'))
			    if tax.setmode.v == 0 then
			    	imgui.PushItemWidth(100)
        	        imgui.InputInt(u8"Óêàæèòå òî÷íîå ÊÄ (â ìèíóòàõ)", tax.exact,1)      
        	    end
        	    if tax.setmode.v == 1 then
        	    	imgui.PushItemWidth(100)
        	        imgui.InputInt(u8"Óêàæèòå ïðèìåðíîå ÊÄ (â ìèíóòàõ)", tax.rand_min,1)
        	        imgui.SameLine()
        	        imgui.PushItemWidth(100)
        	        imgui.InputInt(u8"##taxrand", tax.rand_max,1)      
        	    end
			    imgui.PopItemWidth()
			    local btnText = tax.active
			    	and u8('Îòêëþ÷èòü')
			    	or u8('Çàïóñòèòü')
			    if imgui.Button(btnText, imgui.ImVec2(200,28)) then
			    	toggleTaxAuto()
			    end
			    imgui.SameLine()
			    imgui.TextQuestion(u8('Ïåðåä çàïóñêîì ðåêîìåíäóåòñÿ ñîõðàíèòü íàñòðîéêè!'))
			    if tax.active then
				    imgui.TextColored(imgui.ImVec4(0.2, 0.8, 0.2, 1), u8'Ñòàòóñ: ðàáîòàåò')
				else
				    imgui.TextColored(imgui.ImVec4(0.8, 0.2, 0.2, 1), u8'Ñòàòóñ: îñòàíîâëåíî')
				end
				imgui.SameLine()
				if tax.active and tax.next_ts > 0 then
				    local left = math.max(0, tax.next_ts - os.time())
				    imgui.Text(u8('Ñëåäóþùàÿ îïëàòà ÷åðåç ') .. math.floor(left / 60) .. u8(' ìèí'))
				end
			end
			PaddingSpace()
			imgui.Separator()
			imgui.CenterText(u8('Àâòîîòêðûòèå ðóëåòîê'))
			imgui.Separator()
			PaddingSpace()
			imgui.Text(u8'Ðåæèì ðàáîòû'); imgui.SameLine() imgui.PushItemWidth(200) imgui.Combo('##aoc.mode', aoc.setmode, aocmode, -1) if aoc.setmode.v == 1 then imgui.SameLine() imgui.TextQuestion(u8('Äàííûé ðåæèì ðàáîòàåò íà íîâîì èíâåíòàðå. Ñêðèïò ñàì âûïîëíÿåò ïîèñê íåîáõîäèìûõ ñóíäóêîâ/òàéíèêîâ ñàìîñòîÿòåëüíî.\nÑêðèïò ïðîâåðÿåò íàëè÷èå: Ñóíäóêà ðóëåòêè, Ïëàòèíîâîãî ñóíäóêà, Òàéíèêîâ Èëîíà Ìàñêà, Ëîñ-Ñàíòîñà, Vice-City, Ôðèðåí.\nÑêðèïò ñàì íàõîäèò èõ ïîëîæåíèå è îòêðûâàåò èõ ïî ïîðÿäêó ðàñïîëîæåíèÿ â èíâåíòàðå.')) end
			if aoc.setmode.v == 0 then
				imgui.BeginGroup()
				imgui.Checkbox(u8('Îòêðûâàòü ñòàíäàðò ñóíäóê'),roulette.standart); imgui.SameLine() imgui.TextQuestion(u8('Äëÿ îïòèìèçàöèè îòêðûâàíèÿ ñóíäóêîâ ñòàíäàðòíûé ñóíäóê äîëæåí áûòü íà ëþáîì ñëîòå íà 1 ñòðàíèöå')) 
				imgui.Checkbox(u8('Îòêðûâàòü äîíàò ñóíäóê'),roulette.donate); imgui.SameLine() imgui.TextQuestion(u8('[Îáÿçàòåëüíî!] Äîíàòíûé ñóíäóê äîëæåí áûòü íà ëþáîì ñëîòå íà 1 ñòðàíèöå'))
				imgui.Checkbox(u8('Îòêðûâàòü ïëàòèíà ñóíäóê'),roulette.platina); imgui.SameLine() imgui.TextQuestion(u8('[Îáÿçàòåëüíî!] Ïëàòèíîâûé ñóíäóê äîëæåí áûòü íà ëþáîì ñëîòå íà 1 ñòðàíèöå'))
				imgui.Checkbox(u8('Îòêðûâàòü òàéíèê Èëîíà Ìàñêà'),roulette.mask); imgui.SameLine() imgui.TextQuestion(u8('[Îáÿçàòåëüíî!] Ñóíäóê Ìàñêà äîëæåí áûòü íà ëþáîì ñëîòå íà 1 ñòðàíèöå'))
				imgui.EndGroup()
				imgui.SameLine(350)
				imgui.BeginGroup()
				imgui.Checkbox(u8('Îòêðûâàòü òàéíèê Ëîñ-Ñàíòîñà'),roulette.tainik); imgui.SameLine() imgui.TextQuestion(u8('[Îáÿçàòåëüíî!] Òàéíèê Ëîñ-Ñàíòîñà äîëæåí áûòü íà ëþáîì ñëîòå íà 1 ñòðàíèöå'))
				imgui.TextDisabled((u8("Îòêðûâàòü òàéíèê Vice-City")), roulette.tainikvc); imgui.SameLine() imgui.TextQuestion(u8('Ñêîðî!'))
				imgui.PushItemWidth(100)
				imgui.InputInt(u8('Çàäåðæêà (â ìèíóòàõ.)##wait'),roulette.wait)
				imgui.SameLine()
				imgui.TextQuestion(u8('Çàäåðæêà ïåðåä ÷åêîì ñîñòîÿíèÿ ðóëåòîê(ìîæíî îòêðûòü èëè íåò)'))
				imgui.PopItemWidth()
				if imgui.Button(u8('Âêëþ÷èòü/âûêëþ÷èòü àâòîîòêðûòèå ñóíäóêîâ')) then 
				    openchestrullet()
				end
			end
			if aoc.setmode.v == 1 then 
				imgui.BeginGroup()
				imgui.PushItemWidth(100)
				imgui.Text(u8'Çàäåðæêà (â ìèíóòàõ)'); imgui.SameLine() imgui.InputInt(u8('##aoc.wait'), aoc.wait)
				if imgui.Button(u8('Âêëþ÷èòü/âûêëþ÷èòü')) then
					newaoc()
				end
			end
			imgui.EndGroup()
			PaddingSpace()
			imgui.Separator()
			imgui.CenterText(u8('Àâòîìàòè÷åñêàÿ îòïðàâêà ñîîáùåíèé'))
			imgui.Separator()
			PaddingSpace()
			imgui.BeginGroup()
			imgui.PushItemWidth(400)
			imgui.InputText(u8('1 Ñòðîêà'),piar.piar1)
			imgui.SameLine()
			imgui.TextQuestion(u8('Îáÿçàòåëüíàÿ ñòðîêà'))
			imgui.InputText(u8('2 Ñòðîêà'),piar.piar2)
			imgui.SameLine()
			imgui.TextQuestion(u8('Îñòàâüòå ñòðîêó ïóñòóþ åñëè íå õîòèòå å¸ èñïîëüçîâàòü'))
			imgui.InputText(u8('3 Ñòðîêà'),piar.piar3)
			imgui.SameLine()
			imgui.TextQuestion(u8('Îñòàâüòå ñòðîêó ïóñòóþ åñëè íå õîòèòå å¸ èñïîëüçîâàòü'))
			imgui.PopItemWidth()
			imgui.EndGroup()
		
			imgui.SameLine()
		
			imgui.BeginGroup()
			imgui.PushItemWidth(80)
			imgui.InputInt(u8('Çàäåðæêà(ñåê.)##piar1'),piar.piarwait); 
			imgui.InputInt(u8('Çàäåðæêà(ñåê.)##piar2'),piar.piarwait2); 
			imgui.InputInt(u8('Çàäåðæêà(ñåê.)##piar3'),piar.piarwait3); 
			imgui.PopItemWidth()
			imgui.EndGroup()
			if imgui.Button(u8('Àêòèâèðîâàòü ôëóäåð')) then 
			    bizpiaron = not bizpiaron
			    activatePiar(bizpiaron)
			    AFKMessage(bizpiaron and 'Ïèàð âêëþ÷¸í!' or 'Ïèàð âûêëþ÷åí!',5)
			end
			imgui.SameLine()
			imgui.Checkbox(u8('ÀâòîÏèàð'),piar.auto_piar) 
			imgui.SameLine()
			imgui.TextQuestion(u8('Åñëè ïîñëå ïîñëåäíåãî âûãðóæåíèÿ ñêðèïòà ïðîéäåò ìåíüøå óêàçàííîãî(â íàñòðîéêàõ) âðåìåíè, âêëþ÷èòüñÿ àâòîïèàð'))
			if piar.auto_piar.v then
			    imgui.SameLine()
			    imgui.PushItemWidth(120)
			    if imgui.InputInt(u8('Ìàêñèìàëüíîå âðåìÿ äëÿ âêëþ÷åíèÿ ïèàðà(â ñåê.)##autpiar'),piar.auto_piar_kd) then
			        if piar.auto_piar_kd.v < 0 then piar.auto_piar_kd = 0 end
			    end
			    imgui.PopItemWidth()
			end
			PaddingSpace()
			imgui.Separator()
			imgui.CenterText(u8('Îñòàëüíûå íàñòðîéêè'))
			imgui.Separator()
			PaddingSpace()
			imgui.BeginGroup()
			if imgui.Checkbox(u8('Fastconnect'),fastconnect) then
				sampFastConnect(fastconnect.v)
			end
			imgui.SameLine()
			imgui.TextQuestion(u8('Áûñòðûé âõîä íà ñåðâåð'))
			if imgui.Checkbox(u8('AntiAFK'),antiafk) then workpaus(antiafk.v) end
			imgui.SameLine()
			imgui.TextQuestion(u8('Âû íå áóäåòå ñòîÿòü â AFK åñëè ñâåðíåòå èãðó\nÂíèìàíèå! Åñëè AntiAFK âêëþ÷åí è âû ñîõðàíèëè íàñòðîéêè òî ïðè ñëåäóåùåì çàõîäå îí àâòîìàòè÷åñêè âêëþ÷èòñÿ! Ó÷òèòå ýòî!'))
			imgui.Checkbox(u8('AutoScreenBan'),banscreen)
			imgui.SameLine()
			imgui.TextQuestion(u8('Åñëè âàñ çàáàíèò àäìèí òî ñêðèí ñäåëàåòñÿ àâòîìàòè÷åñêè'))
			imgui.EndGroup()
			imgui.SameLine(350)
			imgui.BeginGroup()
			imgui.Checkbox(u8('Àâòîîáíîâëåíèå'),autoupdateState)
			imgui.SameLine()
			imgui.TextQuestion(u8('Âêëþ÷àåò àâòîîáíîâëåíèå. Ïî óìîë÷àíèþ âêëþ÷åíî'))
			imgui.SameLine(210)
			imgui.BeginGroup()
			imgui.EndGroup()
			imgui.Checkbox(u8'Óäàëÿòü èãðîêîâ â ðàäèóñå', delplayer.state)
			if delplayer.state.v then
			    imgui.SameLine()
			    imgui.PushItemWidth(80)
			    imgui.InputInt(u8'ÊÄ (ñåê)', delplayer.cd, 1)
			    imgui.PopItemWidth()
			end
			if delplayer.state.v and not delplayer.running then
			    delplayer.running = true
			    startDelPlayerWorker()
			elseif not delplayer.state.v and delplayer.running then
			    delplayer.running = false
			    stopDelPlayerWorker()
			end
			imgui.SameLine()
			imgui.TextQuestion(u8"Ôóíêöèÿ óäàëÿåò âñåõ èãðîêîâ â ðàäèóñå. Î÷åíü ïîëåçíî ïðè ñêóïå ò.ê ïàäàåò øàíñ êðàøà èãðû. ×òîáû âåðíóòü èãðîêîâ - âûêëþ÷èòå ôóíêöèþ è çàéäèòå â èíòó, çàòåì âûéäèòå èç íå¸. Èëè ìîæíî ïðîñòî ïåðåçàéòè â èãðó. ÍÅ ÐÀÁÎÒÀÅÒ ÍÀ ÎÕÐÀÍÍÈÊÀÕ È ÁÎÒÀÕ!")
			imgui.BeginGroup()
			imgui.EndGroup()
			--imgui.Checkbox(u8'Óäàëÿòü ìàøèíû â ðàäèóñå', delcar.state)
			if delcar.state.v then
			    imgui.SameLine()
			    imgui.PushItemWidth(80)
			    imgui.InputInt(u8'ÊÄ (ñåê)', delcar.cd, 1)
			    imgui.PopItemWidth()
			end
			if delcar.state.v and not delcar.running then
			    delcar.running = true
			    startDelCarWorker()
			elseif not delcar.state.v and delcar.running then
			    delcar.running = false
			    stopDelCarWorker()
			end
			imgui.SameLine()
			--imgui.TextQuestion(u8"Ôóíêöèÿ óäàëÿåò ìàøèíû â ðàäèóñå. Àíàëîãè÷åí Óäàëåíèþ èãðîêîâ â ðàäèóñå")
			--[[ imgui.Checkbox(u8('Àâòîëîãèí'),autologinfix.state)
			if autologinfix.state.v then
				imgui.PushItemWidth(130)
				imgui.InputText(u8('Íèê äëÿ âõîäà'), autologinfix.nick)
				imgui.PopItemWidth()
			end
			if autologinfix.state.v then
				imgui.PushItemWidth(130)
				imgui.InputText(u8('Ïàðîëü äëÿ âõîäà'), autologinfix.pass, showpass and 0 or imgui.InputTextFlags.Password)
				imgui.PopItemWidth()
				if imgui.Button(u8('Ïîêàçàòü##1010')) then showpass = not showpass end
			end]]

			imgui.EndGroup()
			PaddingSpace()
			imgui.Separator()
			imgui.CenterText(u8('Ñêðèïòû ïî îòäåëüíîñòè'))
			imgui.Separator()
			PaddingSpace()
			imgui.BeginGroup()
			-- Cosmo --
			if imgui.Button(u8('Ñêà÷àòü VIP-Resend by Cosmo')) then
				downloadUrlToFile('https://github.com/SMamashin/AFKTools/raw/main/scripts/vip-resend.lua',
                   'moonloader\\vip-resend.lua', 
                   'vip-resend.lua')
				sampAddChatMessage("{FF8000}[AFKTools]{FFFFFF} VIP-Resend óñïåøíî çàãðóæåí! Íàæìèòå Ctrl+R äëÿ ïåðåçàïóñêà MoonLoader.", -1)
            end
			imgui.SameLine()
			imgui.TextQuestion(u8("Ñêðèïò îò íàøåãî äðóãà Cosmo, ïîçâîëÿåò ñêèïàòü äèàëîã ðåêëàìû â /vr"))
			-- AIR -- 
			imgui.SameLine()
			if imgui.Button(u8('Ñêà÷àòü AntiAFK by AIR')) then
				downloadUrlToFile('https://github.com/SMamashin/AFKTools/raw/main/scripts/AntiAFK_1.4_byAIR.asi',
                getGameDirectory()..'\\AntiAFK_1.4_byAIR.asi',
                'AntiAFK_1.4_byAIR.asi')
				sampAddChatMessage("{FF8000}[AFKTools]{FFFFFF} AntiAFK óñïåøíî çàãðóæåí! Ïåðåçàéäèòå ïîëíîñòüþ â èãðó, ÷òîáû îí çàðàáîòàë.", -1)
            end
			imgui.SameLine()
			imgui.TextQuestion(u8("ASI-Ïëàãèí îò A.I.R, îòëè÷íûé AntiAFK äëÿ ëàóí÷åðà, íà ñëó÷àé ïðîáëåì ñ íàøåé Lua-âåðñèåé."))
			-- BoxSet --
			imgui.SameLine()
			if imgui.Button(u8('Àâòîîòðêûòèå ñóíäóêîâ /boxset')) then
				downloadUrlToFile('https://github.com/SMamashin/AFKTools/raw/main/scripts/open_roulettes.lua',
                   'moonloader\\open_roulettes.lua', 
                   'open_roulettes.lua')
				sampAddChatMessage("{FF8000}[AFKTools]{FFFFFF} Open_Roulettes(/boxset) óñïåøíî çàãðóæåí! Íàæìèòå Ctrl+R äëÿ ïåðåçàïóñêà MoonLoader.", -1)
            end
            imgui.SameLine()
			imgui.TextQuestion(u8('/boxset - óñòàðåâøàÿ àëüòåðíàòèâà íàøåìó àâòîîòêðûòèþ, âðîäå åù¸ ðàáîòàåò.'))
			-- AFKTools reloader --
			imgui.SameLine()
			if imgui.Button(u8('AFKTools reloader')) then
				downloadUrlToFile('https://github.com/SMamashin/AFKTools/raw/main/scripts/AFKTools_reloader.lua',
                   'moonloader\\AFKTools_reloader.lua', 
                   'AFKTools_reloader.lua')
				sampAddChatMessage("{FF8000}[AFKTools]{FFFFFF} AFKTools reloader óñïåøíî çàãðóæåí! Íàæìèòå Ctrl+R äëÿ ïåðåçàïóñêà MoonLoader", -1)
            end
            imgui.SameLine()
			imgui.TextQuestion(u8('Äàííûé ñêðèïò ñìîæåò ïåðåçàïóñòèòü AFKTools â ñëó÷àå åãî êðàøà ïî êîìàíäå !afkreload èç VK/TG'))
			-- Libs --
		--[[	imgui.SameLine()
			if imgui.Button(u8('Ñêà÷àòü íóæíûå áèáëèîòåêè')) then
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
				AFKMessage('Áèáëèîòåêè óñïåøíî çàãðóæåíû!')
			end
			imgui.SameLine()
			imgui.TextQuestion(u8('Â moonloader/lib - áóäóò çàãðóæåíû äîïîëíèòåëüíûå áèáëèîòåêè èñïîëüçóåìûå â íàøåì ñêðèïòå.'))
			imgui.SameLine()]]
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

		-- Àâòî-åäà -- 

		elseif menunum == 3 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('Àâòîåäà ') .. fa.ICON_CUTLERY)
			imgui.Separator()
			imgui.BeginGroup()
        	imgui.RadioButton(u8'Îôôíóòü',eat.eatmetod,0)
			if eat.eatmetod.v > 0 then
				imgui.SameLine()
				imgui.PushItemWidth(140)
				imgui.Combo(u8('Ñïîñîá ïðîâåðêè ãîëîäà'), eat.checkmethod, checklist, -1)
				if eat.checkmethod.v == 1 then
					imgui.PushItemWidth(80)
					imgui.SameLine()
					imgui.InputInt(u8('Ïðè ñêîëüêè ïðîöåíòàõ ãîëîäà íàäî êóøàòü'),eat.eat2met,0)
				end
				if eat.checkmethod.v == 2 then
					imgui.PushItemWidth(80)
					imgui.SameLine()
					imgui.InputInt(u8('Ïðè ñêîëüêè ïðîöåíòàõ ãîëîäà íàäî êóøàòü?         '),eat.eat2met,0)
					imgui.SameLine()
					imgui.Text(
					    cefSatiety
					    and (u8('Ãîëîä ') .. cefSatiety .. '%')
					    or  u8('Ãîëîä ')
					)
				end
				imgui.PopItemWidth()
			end
			imgui.RadioButton(u8'Êóøàòü Äîìà',eat.eatmetod,1)
        	imgui.SameLine()
        	imgui.TextQuestion(u8'Âàø ïåðñîíàæ áóäåò êóøàòü äîìà èç õîëîäèëüíèêà')
        	imgui.BeginGroup()
        	imgui.RadioButton(u8'Êóøàòü âíå Äîìà',eat.eatmetod,2)
        	imgui.SameLine()
        	imgui.TextQuestion(u8'Âàø ïåðñîíàæ áóäåò êóøàòü âíå äîìà ñïîñîáîì èç ñïèñêà')
        	if eat.eatmetod.v == 2 then
        	    imgui.Text(u8'Âûáîð ìåòîäà åäû:')
        	    imgui.PushItemWidth(100)
        	    imgui.Combo('##123123131231232', eat.setmetod, metod, -1)
        	    if eat.setmetod.v == 3 then
        	        imgui.Text(u8("ID TextDraw'a Åäû"))
        	        imgui.InputInt(u8"##eat", eat.arztextdrawid,0)      
        	    end    
        	    imgui.PopItemWidth()
        	end
        	imgui.EndGroup()
        	imgui.RadioButton(u8'Êóøàòü â Ôàì ÊÂ',eat.eatmetod,3)
        	imgui.SameLine()
        	imgui.TextQuestion(u8'Âàø ïåðñîíàæ áóäåò êóøàòü èç õîëîäèëüíèêà â ñåìåéíîé êâàðòèðå. Äëÿ èñïîëüçîâàíèÿ âñòàíüòå íà ìåñòî, ãäå ïðè íàæàòèè ALT ïîÿâèòñÿ äèàëîã ñ âûáîðîì åäû')
        	imgui.EndGroup()
        	imgui.BeginGroup()
        	imgui.Checkbox(u8'ÀâòîÕèë', eat.healstate)
        	-- imgui.SameLine()
        	if eat.healstate.v then
        	    imgui.PushItemWidth(40)
        	    imgui.InputInt(u8'Óðîâåíü HP äëÿ Õèëà', eat.hplvl,0)
        	    imgui.PopItemWidth()
        	    imgui.Text(u8 'Âûáîð ìåòîäà õèëà:')
        	    imgui.PushItemWidth(100)
				imgui.Combo('##ban',eat.hpmetod,healmetod,-1)
				if eat.hpmetod.v == 1 then
        	        imgui.PushItemWidth(30)
        	        imgui.InputInt(u8"Êîë-âî íàðêî",eat.drugsquen,0)
        	        imgui.PopItemWidth()
        	    end
        	    if eat.hpmetod.v == 4 then
        	        imgui.Text(u8("ID TextDraw'a Õèëà"))
        	        imgui.InputInt(u8"##heal",eat.arztextdrawidheal,0)
        	    end
        	    imgui.PopItemWidth()
        	end
        	imgui.EndGroup()
        	imgui.SameLine(130)
        	if imgui.Checkbox(u8('Âêëþ÷èòü îòîáðàæåíèå ID òåêñòäðàâîâ'), imgui.ImBool(idsshow)) then
        	    idsshow = not idsshow
        	end
			imgui.EndChild()

		-- Ðàçäåë F.A.Q -- 	

		elseif menunum == 4 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('Èíôîðìàöèÿ & F.A.Q ') .. fa.ICON_INFO)
			imgui.Separator()
			imgui.SetCursorPosX(280)
			imgui.Image(banner, imgui.ImVec2(400, 200))
			imgui.Spacing()
			--imgui.Text(fa.ICON_FILE_CODE_O)
			--imgui.SameLine()
			imgui.Text(fa.ICON_FILE_CODE_O .. u8(scriptinfo))
			PaddingSpace()
			if imgui.CollapsingHeader(u8('Êîìàíäû ñêðèïòà ') .. fa.ICON_COG) then
				imgui.TextWrapped(u8(scriptcommand))
			end
			--imgui.SetCursorPosX(20) -- ïîçâîëÿåò çàäàòü ïîëîæåíèå ôóíêöèè ïî ãîðèçíîòàëè
			--imgui.SetCursorPosY(100) -- ïîçâîëÿåò çàäàòü ïîëîæåíèå ôóíêöèè ïî âåðòèêàëè
			PaddingSpace()
			imgui.Text(u8("Äëÿ ïîëüçîâàòåëåé ñêðèïòà "))-- .. fa.ICON_USER)
			if imgui.Button(u8('Ãðóïïà ') .. fa.ICON_VK  ..u8(' - (Info)')) then
				os.execute("start https://vk.com/notify.arizona")
			end
			imgui.SameLine()
			if imgui.Button(u8('Áåñåäà ') .. fa.ICON_COMMENTS .. u8(' - (Help/Support)')) then
				os.execute("start https://vk.me/join/OznKTxWIyyzo20jNxgdqqNkop85ZPJE1Xa0=")
			end
			imgui.Spacing()
			imgui.Text(u8("Ñâÿçü ñ ðàçðàáîò÷èêàìè ")) --.. fa.ICON_ENVELOPE)
			if imgui.Button(fa.ICON_VK .. u8(' - Bakhusse')) then
				os.execute("start https://vk.com/sk33z")
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_VK .. u8(' - Mamashin')) then
				os.execute("start https://vk.com/evangelion1995")
			end
			imgui.Spacing()
			imgui.Spacing()

			imgui.Text(u8("Äðóãîå"))
			if imgui.Button(u8('BlastHack - òåìà')) then
				os.execute("start https://vk.com/evangelion1995")
			end
			imgui.SameLine()
			imgui.ButtonDisabled(u8("AFKTools site - soon"))

			imgui.EndChild()

		-- Ðàçäåë ChangeLog --	

		elseif menunum == 5 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('Èñòîðèÿ îáíîâëåíèé & Èçìåíåíèé ') .. fa.ICON_HISTORY)
			imgui.Separator()
			for i = 1, 3 do imgui.Spacing() end
			imgui.PushItemWidth(100)
			if imgui.CollapsingHeader(u8'v1.0 (Ðåëèç, ôèêñû, íåáîëüøèå äîïîëíåíèÿ)') then
				imgui.TextWrapped(u8(changelog1))
				imgui.Separator()
			elseif imgui.CollapsingHeader(u8'v2.0 (Äîïîëíåíèÿ, ôèêñû, ðàáîòà ñ VK Notf)') then
				imgui.TextWrapped(u8(changelog2))
				imgui.Separator()
			elseif imgui.CollapsingHeader(u8'v2.2 (Íîâûå ôóíêöèè, äîëíåíèÿ, áàãîôèêñ)') then
				imgui.TextWrapped(u8(changelog3))
				imgui.Separator()
			elseif imgui.CollapsingHeader(u8'v2.5 (Íåáîëüøèå èçìåíåíèÿ, íîâûé àâòîëîãèí, áàãîôèêñ)') then
				imgui.TextWrapped(u8(changelog4))
				imgui.Separator()
			elseif imgui.CollapsingHeader(u8'v3.0 (Ãëîáàëüíîå îáíîâëåíèå, TG Notifications, êàñòîìèçàöèÿ è äð.)') then
				imgui.TextWrapped(u8(changelog5))
				imgui.Separator()
			elseif imgui.CollapsingHeader(u8'v3.1-v3.3 (Èñïðàâëåíèÿ îøèáîê, äîëãàÿ ïàóçà, íîâûå ôóíêöèè)') then
				imgui.TextWrapped(u8(changelog6))
				imgui.Separator()
			end
			imgui.PopItemWidth()
			imgui.EndChild()

		-- Ðàçäåë êàñòîìèçàöèè --

		elseif menunum == 6 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('Êàñòîìèçàöèÿ ') .. fa.ICON_COGS)
			imgui.Separator()
			imgui.Text(u8(customtext))

			-- Theme's System --
			imgui.PushItemWidth(300)
			-- stepace5()
			if imgui.Combo(u8"Âûáåðèòå òåìó", style_selected, style_list, style_selected) then
				style(style_selected.v) 
				mainIni.theme.style = style_selected.v 
				inicfg.save(mainIni, 'AFKTools/AFKTools.ini') 
			end
			-- stepace5()
			-- imgui.Text(u8'Âñå ImGUI ïðåññåòû, êðîìå  áûëè âçÿòû îòñþäà - blast.hk/threads/25442')
			imgui.Separator()
			imgui.CenterText(u8('Ïîëîæåíèå èíôîáàðà ') .. fa.ICON_TAG)
			imgui.Separator()
			host = host or sampGetCurrentServerName()
			local acc = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) .. '['..select(2,sampGetPlayerIdByCharHandle(playerPed))..']'
			local preview = applyInfobar("Test notification")
			imgui.Text(u8('Âû ìîæåòå èçìåíèòü ïîëîæåíèå èíôîáàðà ïðè óâåäîìëåíèÿõ â VK/TG.'))
			imgui.Text(u8('Ïðèìåð óâåäîìëåíèÿ:'))
			imgui.BeginChild("preview", imgui.ImVec2(550, 45), true)
			imgui.TextWrapped(u8(preview))
			imgui.EndChild()
			imgui.PopItemWidth()
			imgui.Columns(3, "infobar_layout", false)
			imgui.SetColumnWidth(0, 180)
			imgui.SetColumnWidth(1, 320)

			-- ÊÎËÎÍÊÀ 1
			imgui.RadioButton(u8'Ñâåðõó',infobar.style,0)
			imgui.SameLine()
			imgui.TextQuestion(u8'Ïðèìåð')

			imgui.RadioButton(u8'Ñíèçó',infobar.style,1)
			imgui.SameLine()
			imgui.TextQuestion(u8'Ïðèìåð')

			imgui.RadioButton(u8'Îòêëþ÷èòü',infobar.style,2)
			imgui.SameLine()
			imgui.TextQuestion(u8'Ïðèìåð')

			imgui.NextColumn()

			-- ÊÎËÎÍÊÀ 2
			imgui.RadioButton(u8'Êàñòîìíûé',infobar.style,3)
			imgui.SameLine()
			imgui.TextQuestion(u8'Èíôîáàð, êîòîðûé äåëàåòå âû!')

			if infobar.style.v == 3 then
			    imgui.Text(u8("Ïîçèöèÿ êàñòîìíîãî èíôîáàðà"))
			    imgui.RadioButton(u8"Ñâåðõó##cpos1", infobar.custom_pos, 0)
			    imgui.SameLine()
			    imgui.RadioButton(u8"Ñíèçó##cpos2", infobar.custom_pos, 1)

			    imgui.Spacing()
			    imgui.Text(u8("Øàáëîí êàñòîìíîãî èíôîáàðà"))

			    imgui.PushItemWidth(280)
			    imgui.InputText(u8"##custom", infobar.custom)
			end

			imgui.NextColumn()

			-- ÊÎËÎÍÊÀ 3
			if infobar.style.v == 3 then
			imgui.Text(u8("Ïåðåìåííûå"))
			imgui.BeginChild("vars", imgui.ImVec2(240,120), true)
				imgui.BulletText(u8("{nick} - íèê"))
				imgui.BulletText(u8("{id} - ID èãðîêà"))
				imgui.BulletText(u8("{server} - ñåðâåð"))

				imgui.BulletText(u8("{money} - äåíüãè"))
				imgui.BulletText(u8("{lvl} - óðîâåíü"))

				imgui.BulletText(u8("{hp} - çäîðîâüå"))
				imgui.BulletText(u8("{armour} - áðîíÿ"))
				imgui.BulletText(u8("{hunger} - ãîëîä"))

				imgui.BulletText(u8("{time} - âðåìÿ"))
				imgui.BulletText(u8("{date} - äàòà"))
			imgui.EndChild()
			end

			imgui.Columns(1)
			imgui.EndChild()

		-- Ðàçäåë ïîèñêà è îòïðàâêè òåêñòà èç èãðû â VK -- --//Ïðîäóáëèðóé äëÿ TGNOTF--// By Mamashin

		elseif menunum == 7 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(u8('Íàñòðîéêà îòïðàâêè òåêñòà ïî ïîèñêó â ÷àòå â ') .. fa.ICON_VK .. " & " .. fa.ICON_TELEGRAM)
			imgui.Separator()
			imgui.Text(u8(searchchatfaq))
			PaddingSpace()
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'Îòïðàâëÿòü íàéäåííûé òåêñò â '.. fa.ICON_VK .. " & " .. fa.ICON_TELEGRAM, find.vkfind) imgui.SameLine() imgui.TextQuestion(u8"Îòïðàâêà íóæíûõ ñòðîê ñ ÷àòà âàì â VK/Telegram. \nÏðèìåð: Ïðîäàì Ìàâåðèê ÒÒ Ñóïðèì")
			imgui.Text('')
			imgui.PushItemWidth(350)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò', find.vkfindtext) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê1', find.inputfindvk)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò2', find.vkfindtext6) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê6', find.inputfindvk6)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò3', find.vkfindtext2) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê2', find.inputfindvk2)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò4', find.vkfindtext7) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê7', find.inputfindvk7)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò5', find.vkfindtext3) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê3', find.inputfindvk3)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò6', find.vkfindtext8) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê8', find.inputfindvk8)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò7', find.vkfindtext4) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê4', find.inputfindvk4)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò8', find.vkfindtext9) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê9', find.inputfindvk9)
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò9', find.vkfindtext5) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê5', find.inputfindvk5)
			imgui.SameLine() 
			imgui.Text('') imgui.SameLine() imgui.Checkbox(u8'##âêîá÷èòüïîèñêòåêñò10', find.vkfindtext10) imgui.SameLine() imgui.InputText(u8'##ïîèñêâê10', find.inputfindvk10)
			imgui.PopItemWidth()
			imgui.EndChild()

		-- Ðàçäåë VK Notf --

		elseif menunum == 8 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(fa.ICON_VK .. ' Notification')
			imgui.Separator()
			if imgui.Checkbox(fa.ICON_VK .. u8(' - Âêëþ÷èòü óâåäîìëåíèÿ'), vknotf.state) then
				if vknotf.state.v then
					longpollGetKey()
				end
			end
			if vknotf.state.v then
				imgui.BeginGroup()
				if vkerr then
					imgui.Text(u8'Ñîñòîÿíèå ïðè¸ìà: ' .. u8(vkerr))
					imgui.Text(u8'Äëÿ ïåðåïîäêëþ÷åíèÿ ê ñåðâåðàì íàæìèòå êíîïêó "Ïåðåïîäêëþ÷èòüñÿ ê ñåðâåðàì"')
				else
					imgui.Text(u8'Ñîñòîÿíèå ïðè¸ìà: Àêòèâíî!') --
				end
				if vkerrsend then
					imgui.SameLine()
					imgui.Text(u8'Ñîñòîÿíèå îòïðàâêè: ' .. u8(vkerrsend))
				else
					imgui.SameLine()
					imgui.Text(u8'Ñîñòîÿíèå îòïðàâêè: Àêòèâíî!')
				end
				imgui.InputText(u8('Òîêåí'), vknotf.token, showtoken and 0 or imgui.InputTextFlags.Password)
				imgui.SameLine()
				if imgui.Button(u8('Ïîêàçàòü##1010')) then showtoken = not showtoken end
				imgui.InputText(u8('VK ID Ãðóïïû'), vknotf.group_id)
				imgui.SameLine()
				imgui.TextQuestion(u8('Â öèôðàõ!'))
				imgui.InputText(u8('VK ID'), vknotf.user_id)
				imgui.SameLine()
				imgui.TextQuestion(u8('Â öèôðàõ!'))
				imgui.SetNextWindowSize(imgui.ImVec2(666,200)) -- ñ ïàáëèêîì (600,230)  áåç (900,530)
				if imgui.BeginPopupModal('##howsetVK',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
					imgui.Text(u8(howsetVK))
					if imgui.Button(u8('Ãðóïïà ') .. fa.ICON_VK) then
						os.execute("start https://vk.com/notify.arizona")
					end
					imgui.SameLine()
					if imgui.Button(u8('Áåñåäà ') .. fa.ICON_COMMENTS) then
						os.execute("start https://vk.me/join/OznKTxWIyyzo20jNxgdqqNkop85ZPJE1Xa0=")
					end
					imgui.SameLine()
					if imgui.Button(u8('Ãàéä ') .. fa.ICON_BOOKMARK_O) then
						os.execute("start https://vk.com/@notify.arizona-kak-podkluchit-svoe-soobschestvo")
					end
					imgui.SetCursorPosY(160) -- ñ ïàáëèêîì (200)  áåç (490)
					local wid = imgui.GetWindowWidth()
					imgui.SetCursorPosX(wid / 2 - 30)
					if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(60,20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
				if imgui.Button(u8('Êàê íàñòðîèòü')) then imgui.OpenPopup('##howsetVK') end
				imgui.SameLine()
				imgui.SetNextWindowSize(imgui.ImVec2(600,200)) -- 600,200
                if imgui.BeginPopupModal('##howscreen',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
					imgui.Text(u8(howscreen))
					imgui.SetCursorPosY(150)
					local wid = imgui.GetWindowWidth()
					imgui.SetCursorPosX(wid / 2 - 30)
					if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(60,20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
				if imgui.Button(u8('Ïðîâåðèòü óâåäîìëåíèÿ')) then sendvknotf('Ñêðèïò ðàáîòàåò!') end
				imgui.SameLine()
				if imgui.Button(u8('Ïåðåïîäêëþ÷èòüñÿ ê ñåðâåðàì')) then longpollGetKey() end
				imgui.EndGroup()
				for i = 1, 3 do imgui.Spacing() end
				imgui.Separator()
				imgui.CenterText(u8('Ñîáûòèÿ, ïðè êîòîðûõ îòïðàâèòüñÿ óâåäîìëåíèå'))
				imgui.Separator()
				imgui.BeginGroup()
				imgui.Checkbox(u8('Ïîäêëþ÷åíèå'),vknotf.isinitgame); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïîäêëþ÷èòñÿ ê ñåðâåðó'))
				imgui.Checkbox(u8('Àäìèíèñòðàöèÿ'),vknotf.isadm); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè â ñòðîêå áóäåò ñëîâî "Àäìèíèñòðàòîð" + âàø íèê + êðàñíàÿ ñòðîêà(èñêë.: îêíî /pm, ÷àò /pm, ban òîæå áóäóò ó÷èòûâàòüñÿ)'))
				imgui.Checkbox(u8('Ãîëîä'),vknotf.ishungry); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïðîãîëîäàåòñÿ'))
				imgui.Checkbox(u8('Êèê'),vknotf.iscloseconnect); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ îòêëþ÷èòñÿ îò ñåðâåðà'))
				imgui.Checkbox(u8('Äåìîðãàí'),vknotf.isdemorgan); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ âûéäåò èç äåìîðãàíà'))
				imgui.Checkbox(u8('SMS è Çâîíîê'),vknotf.issmscall); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæó ïðèäåò ñìñ èëè ïîçâîíÿò'))
				imgui.Checkbox(u8('Çàïèñü çâîíêîâ'),vknotf.record); imgui.SameLine(); imgui.TextQuestion(u8('Çàïèñü çâîíêà, îòïðàâëÿåòñÿ â ÂÊ. Ðàáîòàåò ñ àâòîîòâåò÷èêîì'))
				imgui.Checkbox(u8('Âõîäÿùèå è èñõîäÿùèå ïåðåâîäû'),vknotf.bank); imgui.SameLine(); imgui.TextQuestion(u8('Ïðè ïîëó÷åíèè èëè îòïðàâëåíèè ïåðåâîäà ïðèäåò óâåäîìëåíèå'))
				imgui.EndGroup()
				imgui.SameLine(300)
				imgui.BeginGroup()
				imgui.Checkbox(u8('PayDay'),vknotf.ispayday); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïîëó÷èò PayDay'))
				imgui.Checkbox(u8('Ñìåðòü'),vknotf.islowhp); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ óìðåò(åñëè âàñ êòî-òî óáúåò, íàïèøåò åãî íèê)'))
				imgui.Checkbox(u8('Êðàø/çàïóñê ñêðèïòà'),vknotf.iscrashscript); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ñêðèïò âûãðóçèòñÿ/êðàøíåòñÿ/çàïóñòèòñÿ(äàæå åñëè ïåðåçàãðóçèòå ÷åðåç CTRL + R)'))
				imgui.Checkbox(u8('Ïðîäàæè'),vknotf.issellitem); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïðîäàñò ÷òî-òî íà ÖÐ èëè ÀÁ'))
				imgui.Checkbox(u8('ÊÄ ìåøêà/ðóëåòîê'),vknotf.ismeat); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ÊÄ íà ìåøîê/ñóíäóê íå ïðîøëî, èëè åñëè âûïàäåò ðóëåòêà òî ïðèäåò óâåäîìëåíèå'))
				imgui.Checkbox(u8('Êîä ñ ïî÷òû/ÂÊ'),vknotf.iscode); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè áóäåò òðåáîâàòüñÿ êîä ñ ïî÷òû/ÂÊ, òî ïðèäåò óâåäîìëåíèå'))
				imgui.Checkbox(u8('Îòïðàâêà âñåõ äèàëîãîâ'),vknotf.dienable); imgui.SameLine(); imgui.TextQuestion(u8('Ñêðèïò îòïðàâëÿåò âñå ñåðâåðíûå äèàëîãè ïî òèïó /mm, /stats â âàøó áåñåäó â VK.'))
				imgui.Checkbox(u8('Óïîìèíàíèÿ'),vknotf.mentions); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè âàñ óïîìÿíóò â ÷àòå - ñêðèïò îá ýòîì ñîîáùèò!'))
				imgui.EndGroup()
				imgui.SameLine(600)
				imgui.BeginGroup()
				imgui.Checkbox(u8('Îïëàòà íàëîãîâ'),vknotf.taxes); imgui.SameLine(); imgui.TextQuestion(u8('Ïðè îïëàòå íàëîãîâ ïîñòóïèò óâåäîìëåíèå!'))
				imgui.EndGroup()
			end
			imgui.EndChild()

		-- Ðàçäåë TG Notf -- 
			
		elseif menunum == 9 then
			imgui.BeginChild('##ana',imgui.ImVec2(-1,-1),false)
			imgui.CenterText(fa.ICON_TELEGRAM .. ' Notification')
			imgui.Separator()
			if imgui.Checkbox(fa.ICON_TELEGRAM .. u8(' - Âêëþ÷èòü óâåäîìëåíèÿ'), tgnotf.state) then
				if tgnotf.state.v then
					longpollGetKey()
				end
			end
			if tgnotf.state.v then
				imgui.BeginGroup()
				imgui.InputText(u8('Òîêåí'), tgnotf.token, showtoken and 0 or imgui.InputTextFlags.Password)
				imgui.SameLine()
				if imgui.Button(u8('Ïîêàçàòü##1010')) then showtoken = not showtoken end
				imgui.InputText(u8('TG ID'), tgnotf.user_id)
				imgui.SameLine()
				imgui.TextQuestion(u8('User ID â öèôðàõ!'))
				if imgui.Button(u8('Ïðîâåðèòü óâåäîìëåíèÿ')) then sendtgnotf('Ñêðèïò ðàáîòàåò!') end
				imgui.SameLine()
				imgui.SetNextWindowSize(imgui.ImVec2(666,200)) -- ñ ïàáëèêîì (600,230)  áåç (900,530)
				if imgui.BeginPopupModal('##howsetTG',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
					imgui.Text(u8(howsetTG))
					if imgui.Button(u8('Ãðóïïà ') .. fa.ICON_VK) then
						os.execute("start https://vk.com/notify.arizona")
					end
					imgui.SameLine()
					if imgui.Button(u8('Áåñåäà ') .. fa.ICON_COMMENTS) then
						os.execute("start https://vk.me/join/OznKTxWIyyzo20jNxgdqqNkop85ZPJE1Xa0=")
					end
					imgui.SameLine()
					if imgui.Button(u8('Ãàéä ') .. fa.ICON_BOOKMARK_O) then
						os.execute("start https://vk.com/@notify.arizona-kak-podkluchit-svoe-soobschestvo")
					end
					imgui.SetCursorPosY(160) -- ñ ïàáëèêîì (200)  áåç (490)
					local wid = imgui.GetWindowWidth()
					imgui.SetCursorPosX(wid / 2 - 30)
					if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(60,20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
				imgui.SetNextWindowSize(imgui.ImVec2(666,200)) -- ñ ïàáëèêîì (600,230)  áåç (900,530)
				if imgui.BeginPopupModal('##helpTG',true,imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
					imgui.Text(u8(helpTG))
					imgui.SetCursorPosY(170) -- ñ ïàáëèêîì (200)  áåç (490)
					local wid = imgui.GetWindowWidth()
					imgui.SetCursorPosX(wid / 2 - 30)
					if imgui.Button(u8'Ïîíÿòíî', imgui.ImVec2(60,20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndPopup()
				end
				if imgui.Button(u8('Êàê íàñòðîèòü')) then imgui.OpenPopup('##howsetTG') end
				imgui.SameLine()
				if imgui.Button(u8('Èãðà íå ðåàãèðóåò íà ÒÃ')) then imgui.OpenPopup('##helpTG') end
				imgui.SameLine()
				imgui.EndGroup()
				for i = 1, 4 do imgui.Spacing() end
				imgui.Separator()
				imgui.CenterText(u8('Ñîáûòèÿ, ïðè êîòîðûõ îòïðàâèòüñÿ óâåäîìëåíèå'))
				imgui.Separator()
				imgui.Spacing()
				imgui.BeginGroup()
				imgui.Checkbox(u8('Ïîäêëþ÷åíèå'),tgnotf.isinitgame); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïîäêëþ÷èòñÿ ê ñåðâåðó'))
                imgui.Checkbox(u8('Àäìèíèñòðàöèÿ'),tgnotf.isadm); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè â ñòðîêå áóäåò ñëîâî "Àäìèíèñòðàòîð" + âàø íèê + êðàñíàÿ ñòðîêà(èñêë.: îêíî /pm, ÷àò /pm, ban òîæå áóäóò ó÷èòûâàòüñÿ)'))
                imgui.Checkbox(u8('Ãîëîä'),tgnotf.ishungry); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïðîãîëîäàåòñÿ'))
                imgui.Checkbox(u8('Êèê'),tgnotf.iscloseconnect); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ îòêëþ÷èòñÿ îò ñåðâåðà'))
                imgui.Checkbox(u8('Äåìîðãàí'),tgnotf.isdemorgan); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ âûéäåò èç äåìîðãàíà'))
                imgui.Checkbox(u8('SMS è Çâîíîê'),tgnotf.issmscall); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæó ïðèäåò ñìñ èëè ïîçâîíÿò'))
                imgui.Checkbox(u8('Çàïèñü çâîíêîâ'),tgnotf.record); imgui.SameLine(); imgui.TextQuestion(u8('Çàïèñü çâîíêà, îòïðàâëÿåòñÿ â TG. Ðàáîòàåò ñ àâòîîòâåò÷èêîì'))
                imgui.Checkbox(u8('Âõîäÿùèå è èñõîäÿùèå ïåðåâîäû'),tgnotf.bank); imgui.SameLine(); imgui.TextQuestion(u8('Ïðè ïîëó÷åíèè èëè îòïðàâëåíèè ïåðåâîäà ïðèäåò óâåäîìëåíèå'))
                imgui.EndGroup()
                imgui.SameLine(300)
                imgui.BeginGroup()
                imgui.Checkbox(u8('PayDay'),tgnotf.ispayday); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïîëó÷èò PayDay'))
                imgui.Checkbox(u8('Ñìåðòü'),tgnotf.islowhp); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ óìðåò(åñëè âàñ êòî-òî óáúåò, íàïèøåò åãî íèê)'))
                imgui.Checkbox(u8('Êðàø/çàïóñê ñêðèïòà'),tgnotf.iscrashscript); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ñêðèïò âûãðóçèòñÿ/êðàøíåòñÿ/çàïóñòèòñÿ(äàæå åñëè ïåðåçàãðóçèòå ÷åðåç CTRL + R)'))
                imgui.Checkbox(u8('Ïðîäàæè'),tgnotf.issellitem); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ïåðñîíàæ ïðîäàñò ÷òî-òî íà ÖÐ èëè ÀÁ'))
                imgui.Checkbox(u8('ÊÄ ìåøêà/ðóëåòîê'),tgnotf.ismeat); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè ÊÄ íà ìåøîê/ñóíäóê íå ïðîøëî, èëè åñëè âûïàäåò ðóëåòêà òî ïðèäåò óâåäîìëåíèå'))
                imgui.Checkbox(u8('Êîä ñ ïî÷òû/ÂÊ'),tgnotf.iscode); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè áóäåò òðåáîâàòüñÿ êîä ñ ïî÷òû/ÂÊ, òî ïðèäåò óâåäîìëåíèå'))
                imgui.Checkbox(u8('Îòïðàâêà âñåõ äèàëîãîâ'),tgnotf.dienable); imgui.SameLine(); imgui.TextQuestion(u8('Ñêðèïò îòïðàâëÿåò âñå ñåðâåðíûå äèàëîãè ïî òèïó /mm, /stats â âàøó áåñåäó â TG.'))
                --imgui.Checkbox(u8('Ïðèíèìàòü êîìàíäû è íàæàòèå êëàâèø èç TG'),tgnotf.sellotvtg); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè õîòèòå ïèñàòü â ÷àòû, ïèñàòü êîìàíäû, îòêðûâàòü äèàëîãè èç Telegram è òàê äàëåå, òî íóæíî âêëþ÷èòü äàííûé ôóíêöèîíàë. ×òîáû óçíàòü âñå äîñòóïíûå êîìàíäû, ïîñëå âêëþ÷åíèÿ è ïåðåçàïóñêà ñêðèïòà, íàïèøèòå !help â áåñåäå â Telegram.'))
				imgui.Checkbox(u8('Óïîìèíàíèÿ'),tgnotf.mentions); imgui.SameLine(); imgui.TextQuestion(u8('Åñëè âàñ óïîìÿíóò â ÷àòå - ñêðèïò îá ýòîì ñîîáùèò!'))
				imgui.EndGroup()
				imgui.SameLine(600)
				imgui.BeginGroup()
				imgui.Checkbox(u8('Îïëàòà íàëîãîâ'),tgnotf.taxes); imgui.SameLine(); imgui.TextQuestion(u8('Ïðè îïëàòå íàëîãîâ ïîñòóïèò óâåäîìëåíèå!'))
				imgui.EndGroup()
			end
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
	list:AddLine(imgui.ImVec2(a,d),imgui.ImVec2(b,c),convertImVec4ToU32(convertHexToImVec4('a18282')))
	list:AddLine(imgui.ImVec2(b,d),imgui.ImVec2(a,c),convertImVec4ToU32(convertHexToImVec4('a18282')))
	imgui.SetCursorPos(imgui.ImVec2(e,f))
	if imgui.InvisibleButton('##closebutolo',imgui.ImVec2(rad*2,rad*2)) then
		afksets.v = false
	end
end

-- Title main menu logo --
function imgui.RenderLogo()
	imgui.Image(logos,imgui.ImVec2(45,45))
end

-- mini msg menu logo -- 
function imgui.RenderMsgLogo()
	imgui.Image(logos,imgui.ImVec2(30,30))
end


function imgui.CenterText(text) 
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function onCefEvent(event, data)
    if event == 'event.arizonahud.playerSatiety' then
        local value = data:match('%[(%d+)%]')
        cefSatiety = tonumber(value)

        if eat.checkmethod.v == 2 and cefSatiety then
            if cefSatiety > eat.eat2met.v then
                cefEatLock = false
            end

            if cefSatiety <= eat.eat2met.v and not cefEatLock then
                cefEatLock = true
                print('[HUNGER] CEF satiety = '..cefSatiety)
                onPlayerHungry:run()
            end
        end
    end
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
		local saved = inicfg.save(mainIni,'AFKTools/AFKTools.ini')
		if vknotf.iscrashscript.v then
			sendvknotf('Ñêðèïò óìåð :(')
		end	
		if tgnotf.iscrashscript.v then
			sendtgnotf('Ñêðèïò óìåð :(')
		end
	end
end
--ïîëó÷èòü âñå òåêñòäðàâû
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

-- Screen --
function takeScreen()
	if isSampLoaded() then
		memory.setuint8(sampGetBase() + 0x119CBC, 1)
	end
end

-- Spacing -- 
function PaddingSpace()
	for i = 1, 3 do imgui.Spacing()

	end
end

-- AntiAFK --
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
	-- AFKMessage('AntiAFK '..(bool and 'ðàáîòàåò' or 'íå ðàáîòàåò'))
end
function sampFastConnect(bool)
	if bool then 
		writeMemory(sampGetBase() + 0x2D3C45, 2, 0, true)
	else
		writeMemory(sampGetBase() + 0x2D3C45, 2, 8228, true)
	end
end

-- Àâòîçàïîëíåíèå -- 
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

-- Hooks -- 
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

    -- ================= CEF =================
    if id == 220 then
        raknetBitStreamIgnoreBits(bitStream, 8)
        local msgType = raknetBitStreamReadInt8(bitStream)

        -- ---------- CEF RECV ----------
        if msgType == 17 then
            raknetBitStreamIgnoreBits(bitStream, 32)

            local len = raknetBitStreamReadInt16(bitStream)
            if len > 0 and len < 4096 then
                local encoded = raknetBitStreamReadInt8(bitStream)
                local text

                if encoded ~= 0 then
                    text = raknetBitStreamDecodeString(bitStream, len + encoded)
                else
                    text = raknetBitStreamReadString(bitStream, len)
                end

				if text:find('event.arizonahud.playerSatiety') and sampIsLocalPlayerSpawned() then
				    local value = text:match('%[(%d+)%]')
				    cefSatiety = tonumber(value)

				    if eat.checkmethod.v == 2 and cefSatiety then
				        local limit = tonumber(eat.eat2met.v)

				        -- åñëè âûøå ïîðîãà  ñáðàñûâàåì èñòîðèþ
				        if cefSatiety > limit then
				            lastEatSatiety = nil
				            return
				        end

				        -- íèæå èëè ðàâíî ïîðîãó
				        if not lastEatSatiety or cefSatiety < lastEatSatiety then
				            lastEatSatiety = cefSatiety
				            print('[HUNGER TRY EAT]', cefSatiety)
				            onPlayerHungry:run()
				        end
				    end
				end

                -- ---------- ÑÒÀÐÀß ËÎÃÈÊÀ AUTOLOGIN ----------
                if autologinfix.state.v then
                    if text:match("window%.executeEvent%('event%.setActiveView', '%[\"Auth\"%]'%);") then
                        lua_thread.create(function()
                            wait(200)
                            local NICK = mainIni.autologinfix.nick
                            local PASS = mainIni.autologinfix.pass
                            local BITSTREAM = raknetNewBitStream()
                            raknetBitStreamWriteInt8(BITSTREAM, 220)
                            raknetBitStreamWriteInt8(BITSTREAM, 18)
                            raknetBitStreamWriteInt8(
                                BITSTREAM,
                                string.len(string.format("authorization|%s|%s|0", NICK, PASS))
                            )
                            raknetBitStreamWriteInt8(BITSTREAM, 0)
                            raknetBitStreamWriteInt8(BITSTREAM, 0)
                            raknetBitStreamWriteInt8(BITSTREAM, 0)
                            raknetBitStreamWriteString(
                                BITSTREAM,
                                string.format("authorization|%s|%s|0", NICK, PASS)
                            )
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

	if eat.checkmethod.v == 2 then
	    if cefSatiety then
	        -- åñëè ãîëîä ÂÛØÅ ïîðîãà  ñáðàñûâàåì ëîê
	        if cefSatiety > eat.eat2met.v then
	            cefEatLock = false
	        end

	        -- åñëè ãîëîä ÍÈÆÅ èëè ÐÀÂÅÍ ïîðîãó  òðèããåðèì ÎÄÈÍ ÐÀÇ
	        if cefSatiety <= eat.eat2met.v and not cefEatLock then
	            print('get hun > new hud, satiety = '..cefSatiety)
	            cefEatLock = true
	            onPlayerHungry:run()
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
					AFKMessage('[Ñóíäóê ðóëåòêè] ïûòàþñü îòêðûòü ñóíäóê')
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
					AFKMessage('[Äîíàò-ñóíäóê] ïûòàþñü îòêðûòü ñóíäóê')
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
					AFKMessage('[Ïëàòèíîâûé ñóíäóê] ïðîáóþ îòêðûòü ñóíäóê')
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
					AFKMessage('[Òàéíèê Èëîíà Ìàñêà] ïðîáóþ îòêðûòü ñóíäóê')
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
					AFKMessage('[Òàéíèê Ëîñ-Ñàíòîñà] ïðîáóþ îòêðûòü òàéíèê')
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
				sampSendChat('/sprunk')
			end 
		end   
	end
end
function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
	local killer = ''
	if vknotf.islowhp.v then
		if sampGetPlayerHealth(select(2, sampGetPlayerIdByCharHandle(playerPed))) - damage <= 0 and sampIsLocalPlayerSpawned() then
			if playerId > -1 and playerId < 1001 then
				killer = '\nÓáèéöà: '..sampGetPlayerNickname(playerId)..'['..playerId..']'
			end
			sendvknotf('Âàø ïåðñîíàæ óìåð'..killer)
		end
	end
	if tgnotf.islowhp.v then
		if sampGetPlayerHealth(select(2, sampGetPlayerIdByCharHandle(playerPed))) - damage <= 0 and sampIsLocalPlayerSpawned() then
			if playerId > -1 and playerId < 1001 then
				killer = '\nÓáèéöà: '..sampGetPlayerNickname(playerId)..'['..playerId..']'
			end
			sendtgnotf('Âàø ïåðñîíàæ óìåð'..killer)
		end
	end
end
function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)

    if handleTaxDialog(dialogId, style, dialogTitle, text) then
        return false
    end

	if dialogText:find('Âû ïîëó÷èëè áàí àêêàóíòà') then
		if banscreen.v then
			createscreen:run()
		end
		if vknotf.isadm.v then
			local svk = dialogText:gsub('\n','') 
			svk = svk:gsub('\t','') 
			sendvknotf('(warning | dialog) '..svk)
		end
		if tgnotf.isadm.v then
			local svk = dialogText:gsub('\n','') 
			svk = svk:gsub('\t','') 
			sendtgnotf('(warning | dialog) '..svk)
		end
	end
	if fix and dialogText:find("Êóðñ ïîïîëíåíèÿ ñ÷åòà") then
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
    if tgnotf.dienable.v then
		if dialogStyle == 1 or dialogStyle == 3 then
			sendtgnotf('' .. dialogTitle .. '\n' .. dialogText .. '\n\n[______________]\n\n[' .. okButtonText .. '] | [' .. cancelButtonText .. ']' )
		else
			if dialogStyle == 0 then
				dialogkey()
				senddialog2('' .. dialogTitle .. '\n' .. dialogText .. '\n\n[' .. okButtonText .. '] | [' .. cancelButtonText .. ']' )
			else
				sendtgnotf('' .. dialogTitle .. '\n' .. dialogText .. '\n\n[' .. okButtonText .. '] | [' .. cancelButtonText .. ']' )
			end
        end
    end
	if vknotf.isadm.v then
		if dialogText:find('Àäìèíèñòðàòîð (.+) îòâåòèë âàì') then
			local svk = dialogText:gsub('\n','') 
			svk = svk:gsub('\t','') 
			sendvknotf('(warning | dialog) '..svk)
		end
	end
	if tgnotf.isadm.v then
		if dialogText:find('Àäìèíèñòðàòîð (.+) îòâåòèë âàì') then
			local svk = dialogText:gsub('\n','') 
			svk = svk:gsub('\t','') 
			sendtgnotf('(warning | dialog) '..svk)
		end
	end
	if vknotf.iscode.v and dialogText:find('áûëî îòïðàâëåíî') then sendvknotf('Òðåáóåòñÿ êîä ñ ïî÷òû.\nÂâåñòè êîä: !sendcode êîä') end
	if vknotf.iscode.v and dialogText:find('×åðåç ëè÷íîå ñîîáùåíèå Âàì íà ñòðàíèöó') then sendvknotf('Òðåáóåòñÿ êîä ñ ÂÊ.\nÂâåñòè êîä: !sendvk êîä') end
	if vknotf.iscode.v and dialogText:find('Ê ýòîìó àêêàóíòó ïîäêëþ÷åíî ïðèëîæåíèå') then sendvknotf('Òðåáóåòñÿ êîä èç GAuthenticator.\nÂâåñòè êîä: !gauth êîä') end
	--tg
	if tgnotf.iscode.v and dialogText:find('áûëî îòïðàâëåíî') then sendtgnotf('Òðåáóåòñÿ êîä ñ ïî÷òû.\nÂâåñòè êîä: !sendcode êîä') end
	if tgnotf.iscode.v and dialogText:find('×åðåç ëè÷íîå ñîîáùåíèå Âàì íà ñòðàíèöó') then sendtgnotf('Òðåáóåòñÿ êîä ñ ÂÊ.\nÂâåñòè êîä: !sendvk êîä') end
	if tgnotf.iscode.v and dialogText:find('Ê ýòîìó àêêàóíòó ïîäêëþ÷åíî ïðèëîæåíèå') then sendtgnotf('Òðåáóåòñÿ êîä èç GAuthenticator.\nÂâåñòè êîä: !gauth êîä') end
	if gotoeatinhouse then
		local linelist = 0
		for n in dialogText:gmatch('[^\r\n]+') do
			if dialogId == 174 and n:find('Ìåíþ äîìà') then
				print('debug: 174 dialog')
				sampSendDialogResponse(174, 1, linelist, false)
			elseif dialogId == 2431 and n:find('Õîëîäèëüíèê') then
				print('debug: 2431 dialog')
				sampSendDialogResponse(2431, 1, linelist, false)
			elseif dialogId == 185 and n:find('Êîìïëåêñíûé Îáåä') then
				print('debug: 185 dialog')
				sampSendDialogResponse(185, 1, linelist-1, false)
				gotoeatinhouse = false
			end
			linelist = linelist + 1
		end
		return false
	end
	if gethunstate and dialogId == 0 and dialogText:find('Âàøà ñûòîñòü') then
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
		if text:find('ýëåêòðîýíåðãèþ') then
			AFKMessage('Íåâîçìîæíî ïîêóøàòü! Îïëàòèòå êîìóíàëêó!')
			gotoeatinhouse = false
		end
	end
	if vknotf.issellitem.v then 
		if color == -1347440641 and text:find('îò ïðîäàæè') and text:find('êîìèññèÿ') then
			sendvknotf(text)
		end
		if color == 1941201407 and text:find('Ïîçäðàâëÿåì ñ ïðîäàæåé òðàíñïîðòíîãî ñðåäñòâà') then
			sendvknotf('Ïîçäðàâëÿåì ñ ïðîäàæåé òðàíñïîðòíîãî ñðåäñòâà')
		end
	end
	if tgnotf.issellitem.v then 
		if color == -1347440641 and text:find('îò ïðîäàæè') and text:find('êîìèññèÿ') then
			sendtgnotf(text)
		end
		if color == 1941201407 and text:find('Ïîçäðàâëÿåì ñ ïðîäàæåé òðàíñïîðòíîãî ñðåäñòâà') then
			sendtgnotf('Ïîçäðàâëÿåì ñ ïðîäàæåé òðàíñïîðòíîãî ñðåäñòâà')
		end
	end
	if color == -10270721 and text:find('Âû ìîæåòå âûéòè èç ïñèõèàòðè÷åñêîé áîëüíèöû') then
		if vknotf.isdemorgan.v then
			sendvknotf(text)
		end
		if tgnotf.isdemorgan.v then
			sendtgnotf(text)
		end
	end
	if text:find('^Àäìèíèñòðàòîð (.+) îòâåòèë âàì') then
		if vknotf.isadm.v then
			sendvknotf('(warning | chat) '..text)
		end
		if tgnotf.isadm.v then
			sendtgnotf('(warning | chat) '..text)
		end
	end
	if color == -10270721 and text:find('Àäìèíèñòðàòîð') then
		local res, mid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		if res then 
			local mname = sampGetPlayerNickname(mid)
			if text:find(mname) then
				if vknotf.isadm.v then
					sendvknotf(text)
				end
				if tgnotf.isadm.v then
					sendtgnotf(text)
				end
			end
		end
	end

	if find.vkfind.v then 
		if find.vkfindtext.v and text:find(''..u8:decode(find.inputfindvk.v)) or 
		find.vkfindtext2.v and text:find(''..u8:decode(find.inputfindvk2.v)) or 
		find.vkfindtext3.v and text:find(''..u8:decode(find.inputfindvk3.v)) or 
		find.vkfindtext4.v and text:find(''..u8:decode(find.inputfindvk4.v)) or 
		find.vkfindtext5.v and text:find(''..u8:decode(find.inputfindvk5.v)) or 
		find.vkfindtext6.v and text:find(''..u8:decode(find.inputfindvk6.v)) or 
		find.vkfindtext7.v and text:find(''..u8:decode(find.inputfindvk7.v)) or 
		find.vkfindtext8.v and text:find(''..u8:decode(find.inputfindvk8.v)) or 
		find.vkfindtext9.v and text:find(''..u8:decode(find.inputfindvk9.v)) or 
		find.vkfindtext10.v and text:find(''..u8:decode(find.inputfindvk10.v)) then
			if vknotf.state.v then 
				sendvknotf('Ïî ïîèñêó íàéäåíî: '..text)
			end
			if tgnotf.state.v then 
				sendtgnotf('Ïî ïîèñêó íàéäåíî: '..text)
			end
		end
	end

	local nickname_m = sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed)))
	local id_m = select(2,sampGetPlayerIdByCharHandle(playerPed))

	if text:match("Ñîáåñåäíèê îòìåíèë çâîíîê") or text:match('Ó âàñ îòêðûò ìîáèëüíûé òåëåôîí') then sampSendChat('/phone') end
	if vknotf.issmscall.v and text:find('Âàì ïðèøëî íîâîå ñîîáùåíèå!') then sendvknotf(text) end
	if text:find('äîêóðèë(à) ñèãàðåòó è âûáðîñèë(à) îêóðîê') and healthfloat <= eat.hplvl.v then sampSendChat('/smoke') end
	if text:find('ïîïûòàëñÿ çàêóðèòü %(Íåóäà÷íî%)') then sampSendChat('/smoke') end
	if vknotf.bank.v and text:match("Âû ïåðåâåëè") then sendvknotf(text) end
	if vknotf.mentions.v and text:find('@' .. nickname_m) or text:find('@' .. id_m) then sendvknotf('Âàñ óïîìÿíóëè!\n' .. text) end
	if vknotf.taxes.v and text:find('Âû îïëàòèëè âñå íàëîãè íà ñóììó') then sendvknotf(text) end
	if vknotf.bank.v and text:match("Âàì ïîñòóïèë ïåðåâîä íà âàø ñ÷åò â ðàçìåðå") then sendvknotf(text) end
	if autoo.v and text:find('Âû ïîäíÿëè òðóáêó') then sampSendChat(u8:decode(atext.v)) end
	if vknotf.iscode.v and text:find('Íà ñåðâåðå åñòü èíâåíòàðü, èñïîëüçóéòå êëàâèøó Y äëÿ ðàáîòû ñ íèì.') then sendvknotf('Ïåðñîíàæ çàñïàâíåí') end
	if vknotf.ismeat.v and (text:find('Èñïîëüçîâàòü ìåøîê ñ ìÿñîì ìîæíî ðàç â 30 ìèíóò!') or text:find('Âðåìÿ ïîñëå ïðîøëîãî èñïîëüçîâàíèÿ åù¸ íå ïðîøëî!') or text:find('ñóíäóê ñ ðóëåòêàìè è ïîëó÷èëè')) then sendvknotf(text) end
	if vknotf.record.v and (text:find('%[Òåë%]%:') or text:find('Âû ïîäíÿëè òðóáêó') or text:find('Âû îòìåíèëè çâîíîê') or text:find('Çâîíîê îêîí÷åí! Âðåìÿ ðàçãîâîðà')) then sendvknotf(text) end
	if autoo.v and text:find('äëÿ òîãî, ÷òîáû ïîêàçàòü êóðñîð óïðàâëåíèÿ èëè ') then
		PickUpPhone()
		if vknotf.issmscall.v then 
			sendphonecall()
		end
	end
	if tgnotf.issmscall.v and text:find('Âàì ïðèøëî íîâîå ñîîáùåíèå!') then sendtgnotf('Âàì íàïèñàëè ÑÌÑ!') end
	if tgnotf.bank.v and text:match("Âû ïåðåâåëè") then sendtgnotf(text) end
	if tgnotf.mentions.v and text:find('@' .. nickname_m) or text:find('@' .. id_m) then sendtgnotf('Âàñ óïîìÿíóëè!\n' .. text) end
	if tgnotf.taxes.v and text:find('Âû îïëàòèëè âñå íàëîãè íà ñóììó') then sendtgnotf(text) end	
	if tgnotf.bank.v and text:match("Âàì ïîñòóïèë ïåðåâîä íà âàø ñ÷åò â ðàçìåðå") then sendtgnotf(text) end
	if autoo.v and text:find('Âû ïîäíÿëè òðóáêó') then sampSendChat(u8:decode(atext.v)) end
	if tgnotf.iscode.v and text:find('Íà ñåðâåðå åñòü èíâåíòàðü, èñïîëüçóéòå êëàâèøó Y äëÿ ðàáîòû ñ íèì.') then sendtgnotf('Ïåðñîíàæ çàñïàâíåí') end
	if tgnotf.ismeat.v and (text:find('Èñïîëüçîâàòü ìåøîê ñ ìÿñîì ìîæíî ðàç â 30 ìèíóò!') or text:find('Âðåìÿ ïîñëå ïðîøëîãî èñïîëüçîâàíèÿ åù¸ íå ïðîøëî!') or text:find('ñóíäóê ñ ðóëåòêàìè è ïîëó÷èëè')) then sendtgnotf(text) end
	if tgnotf.record.v and (text:find('%[Òåë%]%:') or text:find('Âû ïîäíÿëè òðóáêó') or text:find('Âû îòìåíèëè çâîíîê') or text:find('Çâîíîê îêîí÷åí! Âðåìÿ ðàçãîâîðà')) then sendtgnotf(text) end
	if autoo.v and text:find('äëÿ òîãî, ÷òîáû ïîêàçàòü êóðñîð óïðàâëåíèÿ èëè ') then
		PickUpPhone()
		if tgnotf.issmscall.v then 
			sendphonecall()
		end
	end

	if vknotf.ispayday.v then
	    if text:find('Áàíêîâñêèé ÷åê') then
	        vknotf.ispaydaystate = true
	        vknotf.ispaydaytext = ''
	    end

	    if vknotf.ispaydaystate then
	        if text:find('Òåêóùàÿ ñóììà â áàíêå')
	        or text:find('Â äàííûé ìîìåíò ó âàñ')
	        or text:find('Òåêóùàÿ ñóììà íà äåïîçèòå')
	        or text:find('Îáùàÿ çàðàáîòíàÿ ïëàòà') 
	        or text:find('Áàëàíñ íà äîíàò') then

	            vknotf.ispaydaytext = vknotf.ispaydaytext .. '\n' .. text
	        end

	        -- åñëè äîøëè äî ïîñëåäíåé ñòðîêè ÈËÈ ïðîøëî 12 ñåêóíäû
	        if text:find('__________________________________________________________________________') then
	            sendvknotf(vknotf.ispaydaytext)
	            vknotf.ispaydaystate = false
	            vknotf.ispaydaytext = ''
	        end
	    end
	end

	if tgnotf.ispayday.v then
	    if text:find('Áàíêîâñêèé ÷åê') then
	        tgnotf.ispaydaystate = true
	        tgnotf.ispaydaytext = ''
	    end

	    if tgnotf.ispaydaystate then
	        if text:find('Òåêóùàÿ ñóììà â áàíêå')
	        or text:find('Â äàííûé ìîìåíò ó âàñ')
	        or text:find('Òåêóùàÿ ñóììà íà äåïîçèòå')
	        or text:find('Îáùàÿ çàðàáîòíàÿ ïëàòà')
	        or text:find('Áàëàíñ íà äîíàò') then

	            tgnotf.ispaydaytext = tgnotf.ispaydaytext .. '\n' .. text
	        end

	        -- åñëè äîøëè äî ïîñëåäíåé ñòðîêè ÈËÈ ïðîøëî 12 ñåêóíäû
	        if text:find('__________________________________________________________________________') then
	            sendtgnotf(tgnotf.ispaydaytext)
	            tgnotf.ispaydaystate = false
	            tgnotf.ispaydaytext = ''
	        end
	    end
	end
end
function sampev.onInitGame(playerId, hostName, settings, vehicleModels, unknown)
	if vknotf.isinitgame.v then
		sendvknotf('Âû ïîäêëþ÷èëèñü ê ñåðâåðó!', hostName)
	end
	if tgnotf.isinitgame.v then
		sendtgnotf('Âû ïîäêëþ÷èëèñü ê ñåðâåðó!', hostName)
	end
end
function sampev.onDisplayGameText(style, time, text)
	-- print('[GameText | '..os.date('%H:%M:%S')..'] '..'style == '..style..', time == '..time..', text == '..text)
	if eat.checkmethod.v == 0 then
		if text == ('You are hungry!') or text == ('~r~You are very hungry!') then
			if vknotf.ishungry.v then
				sendvknotf('Âû ïðîãîëîäàëèñü!')
			end
			if tgnotf.ishungry.v then
				sendtgnotf('Âû ïðîãîëîäàëèñü!')
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
-- ðåêîíû 
-- ðåêîí ñòàíäàðò 
function reconstandart(timewait,bool_close)
	if handle_aurc then
		handle_aurc:terminate()
		handle_aurc = nil
		AFKMessage('Àâòîðåêîííåêò îñòàíîâëåí ò.ê âû èñïîëüçîâàëè îáû÷íûé ðåêîííåêò')
	end
	if handle_rc then
		handle_rc:terminate()
		handle_rc = nil
		AFKMessage('Ïðåäûäóùèé ðåêîííåêò áûë îñòàíîâëåí')
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
				AFKMessage('Ðåêîííåêò ÷åðåç '..timewait2..' ñåêóíä')
				wait(recwaitim)
				sampConnectToServer(sampGetCurrentServerAddress())
			end
		else
			AFKMessage('Ðåêîííåêò...')
			sampConnectToServer(sampGetCurrentServerAddress())
		end  
		handle_rc = nil
	end,timewait, bool_close)
end
--ðåêîí ñ íèêîì 
function reconname(playername,ips,ports)
	if handle_aurc then
		handle_aurc:terminate()
		handle_aurc = nil
		AFKMessage('Àâòîðåêîííåêò îñòàíîâëåí ò.ê âû èñïîëüçîâàëè ðåêîííåêò ñ íèêîì')
	end
	if handle_rc then
		handle_rc:terminate()
		handle_rc = nil
		AFKMessage('Ïðåäûäóùèé ðåêîííåêò áûë îñòàíîâëåí')
	end
	handle_rc = lua_thread.create(function()
		if #playername == 0 then
			AFKMessage('Ââåäèòå íèê äëÿ ðåêîííåêòà')
		else
			closeConnect()
			sampSetLocalPlayerName(playername)
			AFKMessage('Ðåêîííåêò ñ íîâûì íèêîì\n'..playername)
			local ip, port = sampGetCurrentServerAddress()
			ips,ports = ips or ip, ports or port
			sampConnectToServer(ips,ports)
		end 
	end)
end
-- ñîçäàòü autorecon
function goaurc()
	if vknotf.iscloseconnect.v then
		sendvknotf('Ïîòåðÿíî ñîåäèíåíèå ñ ñåðâåðîì')
	end
	if tgnotf.iscloseconnect.v then
		sendtgnotf('Ïîòåðÿíî ñîåäèíåíèå ñ ñåðâåðîì')
	end
	if arec.state.v then
		if handle_aurc then
			handle_aurc:terminate()
			handle_aurc = nil
			AFKMessage('Ïðåäûäóùèé àâòîðåêîííåêò áûë îñòàíîâëåí')
		end
		if handle_rc then
			handle_rc:terminate()
			handle_rc = nil
			AFKMessage('Îáû÷íûé àâòîðåêîííåêò áûë îñòàíîâëåí ò.ê ñðàáîòàë àâòîðåêîííåêò')
		end
		handle_aurc = lua_thread.create(function()
			local ip, port = sampGetCurrentServerAddress()
			local delay = calcReconnectDelay()
			AFKMessage('Ñîåäèíåíèå ïîòåðÿíî. Ðåêîííåêò ÷åðåç '..delay..' ñåêóíä')
			wait(delay * 1000)
			sampConnectToServer(ip,port)
			handle_aurc = nil
		end)
	end
end
--çàêðûòü ñîåäèíåíèå
function closeConnect()
	raknetEmulPacketReceiveBitStream(PACKET_DISCONNECTION_NOTIFICATION, raknetNewBitStream())
	raknetDeleteBitStream(raknetNewBitStream())
end

--//saves
function saveini()
	--login
	mainIni.autologin.state = autologin.state.v
	--infobar
	mainIni.infobar.style = infobar.style.v
	mainIni.infobar.custom = infobar.custom.v
	mainIni.infobar.custom_pos = infobar.custom_pos.v
	--autoreconnect
	mainIni.arec.state = arec.state.v
	mainIni.arec.statebanned = arec.statebanned.v
	mainIni.arec.wait = arec.wait.v
	mainIni.arec.mode = arec.mode.v
	mainIni.arec.r_min = arec.r_min.v
	mainIni.arec.r_max = arec.r_max.v
	--roulette
	mainIni.roulette.standart = roulette.standart.v
	mainIni.roulette.platina = roulette.platina.v
	mainIni.roulette.donate = roulette.donate.v
	mainIni.roulette.mask = roulette.mask.v
	mainIni.roulette.tainik = roulette.tainik.v
	mainIni.roulette.tainikvc = roulette.tainikvc.v
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
	mainIni.vknotf.mentions = vknotf.mentions.v
	mainIni.vknotf.taxes = vknotf.taxes.v
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
	--tg.notf
	mainIni.tgnotf.state = tgnotf.state.v
	mainIni.tgnotf.token = tgnotf.token.v
	mainIni.tgnotf.user_id = tgnotf.user_id.v
	mainIni.tgnotf.isadm = tgnotf.isadm.v
    mainIni.tgnotf.iscode = tgnotf.iscode.v
    mainIni.tgnotf.issmscall = tgnotf.issmscall.v
    mainIni.tgnotf.bank = tgnotf.bank.v
    mainIni.tgnotf.mentions = tgnotf.mentions.v
    mainIni.tgnotf.taxes = tgnotf.taxes.v
    mainIni.tgnotf.record = tgnotf.record.v
    mainIni.tgnotf.ismeat = tgnotf.ismeat.v
    mainIni.tgnotf.dienable = tgnotf.dienable.v
    mainIni.tgnotf.isinitgame = tgnotf.isinitgame.v 
    mainIni.tgnotf.sellotvtg = tgnotf.sellotvtg.v
    mainIni.tgnotf.iscloseconnect = tgnotf.iscloseconnect.v
    mainIni.tgnotf.ishungry = tgnotf.ishungry.v
    mainIni.tgnotf.isdemorgan = tgnotf.isdemorgan.v
    mainIni.tgnotf.islowhp = tgnotf.islowhp.v
    mainIni.tgnotf.ispayday = tgnotf.ispayday.v
    mainIni.tgnotf.iscrashscript = tgnotf.iscrashscript.v
    mainIni.tgnotf.issellitem = tgnotf.issellitem.v
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
	--tax
	mainIni.tax.state = tax.state.v
	mainIni.tax.setmode = tax.setmode.v
	mainIni.tax.exact = tax.exact.v
	mainIni.tax.rand_min = tax.rand_min.v
	mainIni.tax.rand_max = tax.rand_max.v
	--delplayer
	mainIni.delplayer.state = delplayer.state.v
	mainIni.delplayer.cd = delplayer.cd.v
	--delcar
	mainIni.delcar.state = delcar.state.v
	mainIni.delcar.cd = delcar.cd.v
	--aoc
	mainIni.aoc.setmode = aoc.setmode.v
	mainIni.aoc.wait = aoc.wait.v
	--buttons
	mainIni.buttons.binfo = binfo.v
	local saved = inicfg.save(mainIni,'AFKTools/AFKTools.ini')
	AFKMessage('Íàñòðîéêè INI ñîõðàíåíû '..(saved and 'óñïåøíî!' or 'ñ îøèáêîé!'))
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
-- // ñèñòåìà àâòîîáíîâëåíèÿ //--
updates = {}
updates.data = {
	result = false,
	status = '',
	relevant_version = '',
	url_update = '',
	url_json = 'https://raw.githubusercontent.com/SMamashin/AFKTools/main/AFKTools.json' 
}
function updates:getlast(autoupd)
	print('call getlast')
	self.data.status = 'Ïðîâåðÿþ îáíîâëåíèÿ'
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
						self.data.status = '[Error] Îøèáêà ïðè çàãðóçêå JSON ôàëéà!\nÎáðàòèòåñü â òåõ.ïîääåðæêó ñêðèïòà'
						if autoupd then
							AFKMessage(self.data.status)
						end
						f:close()
						return false
					end
					self.data.result = true
					self.data.url_update = info.updateurl
					self.data.relevant_version = info.latest
					self.data.status = 'Äàííûå ïîëó÷åíû'
					f:close()
					os.remove(json)
					return true
				else
					self.data.result = false
					self.data.status = '[Error] Íåâîçìîæíî ïðîâåðèòü îáíîâëåíèå!\n×òî-òî áëîêèðóåò ñîåäèíåíèå ñ ñåðâåðîì\nÎáðàòèòåñü â òåõ.ïîääåðæêó ñêðèïòà'
					if autoupd then
						AFKMessage(self.data.status)
					end
					return false
				end
			else
				self.data.result = false
				self.data.status = '[Error] Íåâîçìîæíî ïðîâåðèòü îáíîâëåíèå!\n×òî-òî áëîêèðóåò ñîåäèíåíèå ñ ñåðâåðîì\nÎáðàòèòåñü â òåõ.ïîääåðæêó ñêðèïòà'
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
			self.data.status = 'Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..self.data.relevant_version
			AFKMessage(self.data.status)
			int_scr_download = downloadUrlToFile(self.data.url_update, thisScript().path, function(id3, status1, p13, p23)
				if status1 == dlstatus.STATUS_ENDDOWNLOADDATA and int_scr_download == id3 then
					AFKMessage('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')
					AFKMessage('Îáíîâëåíèå çàâåðøåíî!')
					goupdatestatus = true          
					lua_thread.create(function() wait(500) thisScript():reload() end)
				end
				if status1 == dlstatus.STATUSEX_ENDDOWNLOAD and int_scr_download == id3 then
					if goupdatestatus == nil then
						self.data.status = 'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóùåíà ñòàðàÿ âåðñèÿ.'
						AFKMessage(self.data.status)
					end
				end
			end)
		else
			self.data.status = 'Îáíîâëåíèå íå òðåáóåòñÿ.'
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
--// ñòèëü, òåìà è ëîãî
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

-- System Theme's -- 

--// Ôóíêöèÿ Style ëåæèò â AFKStyles.lua - îòäåëüíûé ôàéë êîòîðûé ñîäåðæèò â ñåáå ñòèëè è òåìû //--

style(style_selected.v) 


_data ="\x89\x50\x4E\x47\x0D\x0A\x1A\x0A\x00\x00\x00\x0D\x49\x48\x44\x52\x00\x00\x00\x28\x00\x00\x00\x28\x08\x06\x00\x00\x00\x8C\xFE\xB8\x6D\x00\x00\x00\x09\x70\x48\x59\x73\x00\x00\x0B\x13\x00\x00\x0B\x13\x01\x00\x9A\x9C\x18\x00\x00\x3B\x30\x69\x54\x58\x74\x58\x4D\x4C\x3A\x63\x6F\x6D\x2E\x61\x64\x6F\x62\x65\x2E\x78\x6D\x70\x00\x00\x00\x00\x00\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x62\x65\x67\x69\x6E\x3D\x22\xEF\xBB\xBF\x22\x20\x69\x64\x3D\x22\x57\x35\x4D\x30\x4D\x70\x43\x65\x68\x69\x48\x7A\x72\x65\x53\x7A\x4E\x54\x63\x7A\x6B\x63\x39\x64\x22\x3F\x3E\x0A\x3C\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x3D\x22\x61\x64\x6F\x62\x65\x3A\x6E\x73\x3A\x6D\x65\x74\x61\x2F\x22\x20\x78\x3A\x78\x6D\x70\x74\x6B\x3D\x22\x41\x64\x6F\x62\x65\x20\x58\x4D\x50\x20\x43\x6F\x72\x65\x20\x35\x2E\x36\x2D\x63\x31\x33\x38\x20\x37\x39\x2E\x31\x35\x39\x38\x32\x34\x2C\x20\x32\x30\x31\x36\x2F\x30\x39\x2F\x31\x34\x2D\x30\x31\x3A\x30\x39\x3A\x30\x31\x20\x20\x20\x20\x20\x20\x20\x20\x22\x3E\x0A\x20\x20\x20\x3C\x72\x64\x66\x3A\x52\x44\x46\x20\x78\x6D\x6C\x6E\x73\x3A\x72\x64\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x77\x33\x2E\x6F\x72\x67\x2F\x31\x39\x39\x39\x2F\x30\x32\x2F\x32\x32\x2D\x72\x64\x66\x2D\x73\x79\x6E\x74\x61\x78\x2D\x6E\x73\x23\x22\x3E\x0A\x20\x20\x20\x20\x20\x20\x3C\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x20\x72\x64\x66\x3A\x61\x62\x6F\x75\x74\x3D\x22\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x78\x6D\x70\x4D\x4D\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x6D\x6D\x2F\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x73\x74\x45\x76\x74\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x78\x61\x70\x2F\x31\x2E\x30\x2F\x73\x54\x79\x70\x65\x2F\x52\x65\x73\x6F\x75\x72\x63\x65\x45\x76\x65\x6E\x74\x23\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x2F\x31\x2E\x30\x2F\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x64\x63\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x70\x75\x72\x6C\x2E\x6F\x72\x67\x2F\x64\x63\x2F\x65\x6C\x65\x6D\x65\x6E\x74\x73\x2F\x31\x2E\x31\x2F\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x74\x69\x66\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x74\x69\x66\x66\x2F\x31\x2E\x30\x2F\x22\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x78\x6D\x6C\x6E\x73\x3A\x65\x78\x69\x66\x3D\x22\x68\x74\x74\x70\x3A\x2F\x2F\x6E\x73\x2E\x61\x64\x6F\x62\x65\x2E\x63\x6F\x6D\x2F\x65\x78\x69\x66\x2F\x31\x2E\x30\x2F\x22\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3E\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x37\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x3C\x2F\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x6F\x72\x54\x6F\x6F\x6C\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3E\x32\x30\x32\x33\x2D\x30\x37\x2D\x31\x34\x54\x30\x37\x3A\x32\x31\x3A\x34\x36\x2B\x30\x33\x3A\x30\x30\x3C\x2F\x78\x6D\x70\x3A\x43\x72\x65\x61\x74\x65\x44\x61\x74\x65\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3E\x32\x30\x32\x33\x2D\x30\x37\x2D\x31\x34\x54\x30\x37\x3A\x32\x31\x3A\x34\x36\x2B\x30\x33\x3A\x30\x30\x3C\x2F\x78\x6D\x70\x3A\x4D\x65\x74\x61\x64\x61\x74\x61\x44\x61\x74\x65\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3E\x32\x30\x32\x33\x2D\x30\x37\x2D\x31\x34\x54\x30\x37\x3A\x32\x31\x3A\x34\x36\x2B\x30\x33\x3A\x30\x30\x3C\x2F\x78\x6D\x70\x3A\x4D\x6F\x64\x69\x66\x79\x44\x61\x74\x65\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3E\x78\x6D\x70\x2E\x69\x69\x64\x3A\x33\x38\x37\x64\x65\x30\x32\x61\x2D\x35\x37\x64\x32\x2D\x65\x39\x34\x35\x2D\x62\x33\x34\x61\x2D\x35\x35\x30\x30\x35\x65\x62\x63\x31\x62\x32\x37\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x49\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3E\x61\x64\x6F\x62\x65\x3A\x64\x6F\x63\x69\x64\x3A\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x66\x31\x63\x37\x30\x36\x66\x64\x2D\x32\x31\x66\x64\x2D\x31\x31\x65\x65\x2D\x62\x31\x37\x62\x2D\x66\x38\x30\x65\x61\x63\x38\x31\x31\x65\x33\x31\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3E\x78\x6D\x70\x2E\x64\x69\x64\x3A\x38\x66\x35\x31\x63\x61\x66\x39\x2D\x64\x36\x34\x32\x2D\x64\x36\x34\x36\x2D\x62\x65\x30\x38\x2D\x36\x62\x31\x31\x33\x33\x37\x30\x38\x31\x36\x34\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x4F\x72\x69\x67\x69\x6E\x61\x6C\x44\x6F\x63\x75\x6D\x65\x6E\x74\x49\x44\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x72\x64\x66\x3A\x53\x65\x71\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x72\x64\x66\x3A\x70\x61\x72\x73\x65\x54\x79\x70\x65\x3D\x22\x52\x65\x73\x6F\x75\x72\x63\x65\x22\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3E\x63\x72\x65\x61\x74\x65\x64\x3C\x2F\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3E\x78\x6D\x70\x2E\x69\x69\x64\x3A\x38\x66\x35\x31\x63\x61\x66\x39\x2D\x64\x36\x34\x32\x2D\x64\x36\x34\x36\x2D\x62\x65\x30\x38\x2D\x36\x62\x31\x31\x33\x33\x37\x30\x38\x31\x36\x34\x3C\x2F\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3E\x32\x30\x32\x33\x2D\x30\x37\x2D\x31\x34\x54\x30\x37\x3A\x32\x31\x3A\x34\x36\x2B\x30\x33\x3A\x30\x30\x3C\x2F\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3E\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x37\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x3C\x2F\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x72\x64\x66\x3A\x70\x61\x72\x73\x65\x54\x79\x70\x65\x3D\x22\x52\x65\x73\x6F\x75\x72\x63\x65\x22\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3E\x73\x61\x76\x65\x64\x3C\x2F\x73\x74\x45\x76\x74\x3A\x61\x63\x74\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3E\x78\x6D\x70\x2E\x69\x69\x64\x3A\x33\x38\x37\x64\x65\x30\x32\x61\x2D\x35\x37\x64\x32\x2D\x65\x39\x34\x35\x2D\x62\x33\x34\x61\x2D\x35\x35\x30\x30\x35\x65\x62\x63\x31\x62\x32\x37\x3C\x2F\x73\x74\x45\x76\x74\x3A\x69\x6E\x73\x74\x61\x6E\x63\x65\x49\x44\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3E\x32\x30\x32\x33\x2D\x30\x37\x2D\x31\x34\x54\x30\x37\x3A\x32\x31\x3A\x34\x36\x2B\x30\x33\x3A\x30\x30\x3C\x2F\x73\x74\x45\x76\x74\x3A\x77\x68\x65\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3E\x41\x64\x6F\x62\x65\x20\x50\x68\x6F\x74\x6F\x73\x68\x6F\x70\x20\x43\x43\x20\x32\x30\x31\x37\x20\x28\x57\x69\x6E\x64\x6F\x77\x73\x29\x3C\x2F\x73\x74\x45\x76\x74\x3A\x73\x6F\x66\x74\x77\x61\x72\x65\x41\x67\x65\x6E\x74\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3E\x2F\x3C\x2F\x73\x74\x45\x76\x74\x3A\x63\x68\x61\x6E\x67\x65\x64\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x53\x65\x71\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x78\x6D\x70\x4D\x4D\x3A\x48\x69\x73\x74\x6F\x72\x79\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x54\x65\x78\x74\x4C\x61\x79\x65\x72\x73\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x72\x64\x66\x3A\x42\x61\x67\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x72\x64\x66\x3A\x6C\x69\x20\x72\x64\x66\x3A\x70\x61\x72\x73\x65\x54\x79\x70\x65\x3D\x22\x52\x65\x73\x6F\x75\x72\x63\x65\x22\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x4E\x61\x6D\x65\x3E\x41\x46\x4B\x54\x6F\x6F\x6C\x73\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x4E\x61\x6D\x65\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x54\x65\x78\x74\x3E\x41\x46\x4B\x54\x6F\x6F\x6C\x73\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x4C\x61\x79\x65\x72\x54\x65\x78\x74\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x6C\x69\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x42\x61\x67\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x54\x65\x78\x74\x4C\x61\x79\x65\x72\x73\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3E\x33\x3C\x2F\x70\x68\x6F\x74\x6F\x73\x68\x6F\x70\x3A\x43\x6F\x6C\x6F\x72\x4D\x6F\x64\x65\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3E\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67\x3C\x2F\x64\x63\x3A\x66\x6F\x72\x6D\x61\x74\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x74\x69\x66\x66\x3A\x4F\x72\x69\x65\x6E\x74\x61\x74\x69\x6F\x6E\x3E\x31\x3C\x2F\x74\x69\x66\x66\x3A\x4F\x72\x69\x65\x6E\x74\x61\x74\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x74\x69\x66\x66\x3A\x58\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x3E\x37\x32\x30\x30\x30\x30\x2F\x31\x30\x30\x30\x30\x3C\x2F\x74\x69\x66\x66\x3A\x58\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x74\x69\x66\x66\x3A\x59\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x3E\x37\x32\x30\x30\x30\x30\x2F\x31\x30\x30\x30\x30\x3C\x2F\x74\x69\x66\x66\x3A\x59\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x74\x69\x66\x66\x3A\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x55\x6E\x69\x74\x3E\x32\x3C\x2F\x74\x69\x66\x66\x3A\x52\x65\x73\x6F\x6C\x75\x74\x69\x6F\x6E\x55\x6E\x69\x74\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x65\x78\x69\x66\x3A\x43\x6F\x6C\x6F\x72\x53\x70\x61\x63\x65\x3E\x36\x35\x35\x33\x35\x3C\x2F\x65\x78\x69\x66\x3A\x43\x6F\x6C\x6F\x72\x53\x70\x61\x63\x65\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x65\x78\x69\x66\x3A\x50\x69\x78\x65\x6C\x58\x44\x69\x6D\x65\x6E\x73\x69\x6F\x6E\x3E\x34\x30\x3C\x2F\x65\x78\x69\x66\x3A\x50\x69\x78\x65\x6C\x58\x44\x69\x6D\x65\x6E\x73\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x3C\x65\x78\x69\x66\x3A\x50\x69\x78\x65\x6C\x59\x44\x69\x6D\x65\x6E\x73\x69\x6F\x6E\x3E\x34\x30\x3C\x2F\x65\x78\x69\x66\x3A\x50\x69\x78\x65\x6C\x59\x44\x69\x6D\x65\x6E\x73\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x44\x65\x73\x63\x72\x69\x70\x74\x69\x6F\x6E\x3E\x0A\x20\x20\x20\x3C\x2F\x72\x64\x66\x3A\x52\x44\x46\x3E\x0A\x3C\x2F\x78\x3A\x78\x6D\x70\x6D\x65\x74\x61\x3E\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x0A\x3C\x3F\x78\x70\x61\x63\x6B\x65\x74\x20\x65\x6E\x64\x3D\x22\x77\x22\x3F\x3E\xBF\x4A\xD4\xF9\x00\x00\x00\x20\x63\x48\x52\x4D\x00\x00\x7A\x25\x00\x00\x80\x83\x00\x00\xF9\xFF\x00\x00\x80\xE9\x00\x00\x75\x30\x00\x00\xEA\x60\x00\x00\x3A\x98\x00\x00\x17\x6F\x92\x5F\xC5\x46\x00\x00\x0A\x57\x49\x44\x41\x54\x78\xDA\xCC\x98\x7B\x50\x54\x57\x12\x87\xBF\x3B\x0C\x20\x20\x01\x44\xF0\x09\xA2\x99\x44\x44\x44\x7C\xBF\x45\x83\x51\x40\xE3\x23\x12\x34\x66\x90\x05\x1D\x10\x58\x45\x63\x44\xF0\xC1\x82\xEB\x8A\xBA\x5A\xF8\xD8\x19\x15\x28\x23\x32\xC1\xDD\xD5\x28\x26\x16\xC6\x14\xA9\x8D\x15\x4C\xA1\x56\x2C\x56\x31\x1A\xC5\x15\xA3\xD1\xD4\x28\x31\x3E\xA6\x12\xA3\xD0\xFB\x87\x77\xD8\x59\x76\xD4\xF8\xD8\xAA\x74\xD5\xA9\x7B\x6F\x9F\x3E\x7D\x7E\xA7\xFB\x74\x9F\x3E\x57\x11\x11\x7E\xCB\xA4\xE1\x37\x4E\xDA\xE7\x55\xA0\x28\xCA\xAF\x11\xF3\x05\x9C\x81\xEF\x5B\x76\x3C\xC9\x83\xCF\x6D\x41\x11\x79\x6C\x03\xB2\x7D\x7D\x7D\x6F\xB4\x6F\xDF\xFE\x1A\xB0\xCA\x41\xFF\xE3\x0D\x60\x2F\x64\x4A\x3E\xF8\xD4\x00\xD3\x0A\xA3\x1F\x67\xDD\xE1\xDE\xDE\xDE\x5F\x9C\x3C\x79\x12\x4F\x4F\x4F\x7C\x7C\x7C\x7E\x14\x11\x1F\x7B\x19\xFB\x39\x1D\xE9\x7A\x6A\x17\xA7\x17\xC5\x04\x02\xA9\x40\x22\xB0\x25\xAD\x50\xF2\x1E\x23\x9E\x6A\x34\x1A\x09\x08\x08\xE0\xD3\x4F\x3F\x05\x38\xF6\x7F\xDB\x83\xE9\x45\x31\xFE\xC0\x02\x6F\x6F\xEF\xAC\xC5\x8B\x17\x93\x98\x98\x48\x76\x76\x76\xAE\xA2\x28\xDF\x8A\xC8\xFB\x0E\xAC\xB7\x62\xEA\xD4\xA9\x33\x66\xCC\x98\xC1\xAD\x5B\xB7\x48\x4A\x4A\x02\xD8\xF2\xC2\x01\xA6\x17\xC5\x78\x02\x99\xAD\x5B\xB7\x5E\xB6\x70\xE1\x42\x16\x2C\x58\x80\x97\x97\x17\x8D\x8D\x8D\x34\x36\x36\x02\x34\x3A\x00\x37\xCE\xCF\xCF\x6F\xF9\xD6\xAD\x5B\x01\x98\x37\x6F\x1E\x3D\x7C\x07\xFF\x7C\xE5\xCA\x9E\xF2\x17\x06\x30\xBD\x28\xC6\x05\xC8\x72\x73\x73\xCB\x9B\x3B\x77\x2E\x99\x99\x99\xF8\xFA\xFA\x22\x22\x98\xCD\x66\xF2\xF2\xF2\xA8\xAB\xAB\xFB\x8B\x88\xEC\x74\xE4\xDA\xA2\xA2\x22\xDA\xB6\x6D\xCB\xFE\xFD\xFB\xA9\x39\x7C\x8E\x77\x46\xCE\xFF\x52\x51\x94\xDE\x22\xF2\xCF\x67\x8E\x42\xA3\xA1\x02\xA3\xA1\x02\x20\xDB\xC5\xC5\x45\x32\x32\x32\xE4\xDA\xB5\x6B\x62\xA3\x3D\x7B\xF6\x48\x48\x48\x88\x74\x6B\x17\x52\xBB\x60\xC2\xDA\x06\xA3\xA1\x22\xD1\x41\x54\xE6\xC7\xC7\xC7\x8B\x88\xC8\xF5\xEB\xD7\xC5\xDF\xDF\x5F\xD2\xA2\xF2\xEE\x7A\x79\x79\x49\xEF\xDE\xBD\x05\x30\x39\x9A\xD3\x68\xA8\x70\x98\x05\xB4\x0E\x2C\x17\x12\x12\x12\xB2\xEA\x93\x4F\x3E\x21\x20\x20\x00\x80\x03\x07\x0E\x90\x93\x93\xC3\x8D\x6F\x6F\x7F\x3D\x69\x60\x62\x97\x1E\xC3\xFA\xF6\x54\x5D\xDB\xD8\xC2\xB5\x93\x3B\x75\xEA\x94\xB5\x79\xF3\xE6\x87\x66\x4C\x4D\xA5\x5F\xE7\x48\xF6\x1F\xDB\x51\xB3\x69\xD3\xA6\x61\x33\x67\xCE\x24\x2A\x2A\x2A\x55\x51\x94\xB3\x22\xB2\xE9\x59\x4F\x92\xC0\xC0\xC0\x40\x02\x02\x02\x68\x6C\x6C\x24\x22\x22\x82\xE4\x99\xE9\x67\x06\xFA\xBD\x71\x27\xEB\xCD\xCD\x21\x3D\x3A\xF7\x75\x07\xCC\x40\x30\xB0\xD3\x0E\x9C\xA2\x28\xCA\xBE\xED\xDB\xB7\xE3\xE5\xE5\x45\x59\x59\x19\x97\x6A\x6E\x30\xA1\x5F\xFC\xFE\xEF\x7E\xB8\xB8\x45\x8D\x62\x36\x6C\xD8\x80\xB3\xB3\xF3\x46\x45\x51\x5C\x9F\x15\xE0\xA1\x43\x87\x0E\x51\x55\x55\x85\x93\x93\x13\x83\x06\x0D\x22\x34\x70\x60\x8F\xB0\x2E\x83\x3D\x81\x0F\x81\x50\x20\x1E\xA8\x6B\x31\x6E\x6D\x72\x72\x32\x63\xC7\x8E\xE5\xEA\xD5\xAB\xCC\x9D\x3B\x97\x61\xC1\x51\xB7\x80\x64\xA0\xAC\xAC\xAC\x8C\xEA\xEA\x6A\x82\x83\x83\x49\x4F\x4F\x07\xC8\x7D\x26\x80\x46\x43\x85\x74\xF5\xEF\x91\x39\x6F\xDE\x3C\x44\x84\xE5\xCB\x97\x73\xF2\xFB\x2F\xD8\xFD\xE5\x56\x3D\x10\x0B\x7C\xED\x20\x6A\xDF\xEE\xDA\xB5\xEB\x7B\xEB\xD7\xAF\x07\x20\x39\x39\x99\x61\xDD\xC6\xF3\x4A\x87\xB0\xD9\x69\x85\xD1\x16\x11\x91\x37\xFA\xCF\x3C\x92\x91\x91\x81\x88\x90\x9B\x9B\x8B\x9F\x9F\x5F\x96\xA2\x28\xE1\xCF\x54\x2C\x2C\x9C\xB8\xEE\x94\xFB\x4F\xED\x28\x2E\x2E\xC6\xD3\xD3\x93\x55\xAB\x56\xF1\xF9\xE9\x8F\x5E\x7B\xC4\x69\xD1\x4A\xA3\xD1\x94\x95\x94\x94\xE0\xE1\xE1\x41\x71\x71\x31\x37\x2F\x3C\x20\xAA\xCF\xDB\x65\x69\x85\xD1\x7B\x6C\x72\xE3\xC2\xA7\x6D\xD1\xFC\xF8\x12\x3B\x77\xEE\xC4\xCB\xCB\x8B\x95\x2B\x57\xA2\x26\xFC\x67\x3A\x8B\x0F\x0D\x7A\x25\xB2\x66\xD9\xB2\x65\xDC\xBE\x7D\x9B\xC4\xC4\x44\xFA\xF7\xEF\x9F\x94\x5E\x14\x13\xEF\x40\x36\x3F\x23\x23\x83\x11\x23\x46\x50\x5F\x5F\xCF\xC2\x85\x0B\x19\x16\x1C\x75\x1D\x98\xDB\x42\xAE\x6C\xE0\x2B\x91\xB5\x59\x59\x59\xDC\xBD\x7B\x97\xD9\xB3\x67\x13\x1E\x1E\x9E\x9C\x5E\x14\x33\xFD\x59\x00\xCA\xCB\xED\x7B\x26\x85\x77\x88\x20\x2F\x2F\x0F\x45\x51\xD8\xB4\x69\x13\x8A\xA2\xEC\x4C\x2F\x8A\x51\xEC\x22\x3E\x31\x38\x38\x78\x7E\x7E\x7E\x3E\x00\x49\x49\x49\xBC\x16\x1C\x4B\x90\x5F\xF7\xC4\xB4\xC2\xE8\x1F\x5A\x9C\xD9\xD2\xBD\x63\xEF\x59\xA1\xFE\xC3\x59\xB9\x72\x25\x1A\x8D\x86\x8D\x1B\x37\x3E\xD9\x8A\x8F\xCA\x49\x46\x43\x05\xEB\x12\x76\x6F\x77\x76\x76\x96\x6F\xBE\xF9\x46\x44\x44\x66\xCC\x98\x21\xC0\x52\x35\x57\xB6\xD1\x6A\xB5\x72\xEC\xD8\x31\x11\x11\xD9\xB0\x61\x83\x8C\x08\x19\x2F\x46\x43\x45\xD1\xE3\xAA\x9B\xD5\xFA\xB2\x0F\x5C\x5D\x5D\xA5\xAE\xAE\x4E\x44\x44\xE2\xE2\xE2\x04\x88\x7B\x54\x1E\x7C\x6C\xB9\xE5\xE6\xE2\x91\x35\xA1\xEF\xCC\x9F\xE7\xCF\x9F\xFF\x30\x4C\xD7\xAE\x45\xAB\xD5\xAE\x4C\x2F\x8A\xD1\x02\xB9\x8B\x17\x2F\x66\xC0\x80\x01\x9C\x3B\x77\x8E\x25\x4B\x96\x30\x32\x64\xC2\x77\xC0\xC2\x47\xEC\x55\x45\x51\x94\xD4\x25\x65\xFA\x19\x53\xA6\x4C\xC1\xC9\xC9\xA9\x39\xA0\xD4\x48\x7F\xA6\x7A\xD0\x32\x26\x6C\xEA\xD2\x9B\x17\x1E\xB0\x63\xC7\x0E\x2C\x16\x8B\xAD\x40\x9D\x1D\x1E\x1E\x3E\x37\x37\x37\x97\xA6\xA6\x26\x12\x12\x12\x88\xE9\xAD\xA7\xA3\x4F\x97\xF8\xB4\xC2\xE8\xDB\x0E\xC0\xCD\x52\x14\xA5\x69\xF2\xE4\xC9\xA6\x9A\x9A\x1A\x76\xED\xDA\x45\x50\x50\x10\x47\x8F\x1E\x65\xE9\xD2\xA5\x8F\x2D\x22\x7E\x4D\xC1\xBA\x79\x48\xF7\xD7\xBF\xDD\x96\x5F\xC6\x88\xA1\xA3\xEA\xEF\xDF\xBF\x9F\xEC\xEA\xEA\xBA\xA5\xA4\xA4\x04\xAD\x56\xCB\xEA\xD5\xAB\x71\xBD\xDD\x96\xD1\xA1\x93\x37\xA6\x15\x46\xFF\xA3\x05\xB0\x77\x14\x45\xA9\x8A\x8A\x8A\x2A\x3E\x7E\xFC\x38\xFB\xF6\xED\xA3\x57\xAF\x5E\xD4\xD4\xD4\x30\x71\xE2\x44\xA6\x4F\x4C\x40\x1A\x3C\x4C\x46\x43\xC5\x87\xCF\x03\xF0\xBE\xAE\x7D\xE8\x9C\xF8\x88\x05\xAC\x8D\xFF\xAB\xB3\x46\xD1\xF4\xC9\xC9\xC9\x21\x2C\x2C\x8C\x93\x27\x4F\xB2\x62\xC5\x0A\x22\xC3\xA6\xFE\x0B\x58\xD2\x02\x9C\x29\x22\x22\xC2\x5C\x55\x55\x35\xEC\xE0\xC1\x83\xF4\xEB\xD7\x8F\x33\x67\xCE\x10\x17\x17\x47\xDF\xBE\x7D\x69\x75\xA3\x63\xC3\xA2\x49\x05\x24\x8C\x7E\xAF\xFB\x8B\xAA\xA8\xDF\x3F\x78\x62\xD7\x98\x1B\xCE\xE7\x3B\x1F\x39\x72\x84\xA6\xA6\x26\x06\x0C\x18\x40\x70\xEB\xE1\x32\xA2\x47\xCC\xD0\xB4\xC2\xE8\x6A\x3B\x70\x3A\x9D\x4E\x77\xFE\xFC\xF9\xF3\x00\x5C\xB8\x70\x81\x15\x2B\x56\x60\x36\x9B\x99\xD0\x6F\xE6\xD5\xB1\xE1\x6F\x75\x54\x50\x00\x8E\x02\x19\xEA\xF3\xF9\x2A\xEA\xF4\xA2\x98\x2C\x77\x77\xF7\xEF\x4F\x9C\x38\x81\x46\xA3\x21\x27\x27\x07\xEF\xFB\x81\x8C\xE8\x11\x93\x6F\x0F\x4E\xA5\xCB\x97\x2F\x5F\xA6\xA0\xA0\x80\xD3\xA7\x4F\x53\x52\x52\xC2\xD8\xB0\xB8\x2B\x9B\x92\x3E\xEE\xAC\x28\x4A\x47\xA0\x06\xC8\x49\x2B\x8C\xFE\xF8\x49\xD7\x8C\xA7\xB9\x34\xA5\x66\x66\x66\xD2\xBD\x7B\x77\x8E\x1F\x3F\xCE\x9A\x35\x6B\x88\xEA\x33\xFD\x34\xB0\xC2\x41\xEA\xBA\x77\xEF\xDE\xBD\x57\xFF\xFC\xC7\x0D\xBB\x6F\xD6\x2A\x75\x05\x09\xFB\x18\xDF\x4F\xDF\x59\x51\x94\x33\x40\x1C\xD0\x37\xAD\x30\xFA\xE3\x17\x7D\xED\xBC\x74\xE9\xD2\x25\x4E\x9D\x3A\x85\x5E\xAF\x67\xFA\xD0\xDF\x37\x79\xBA\x79\xEB\xD3\x0A\xA3\xEF\x39\x12\x36\x1A\x2A\x04\x78\x4B\xFD\xBC\xA0\x2E\xC4\x9C\x56\x18\xDD\xF4\x54\xD7\xDA\xA7\x11\x6E\xE5\xE2\x9E\xE1\xE5\xD6\x66\xCD\xE8\xD0\x49\xAE\x23\x42\xC6\x2F\x4B\x2F\x8A\xF9\xD3\xA3\x64\x8D\x86\x0A\x57\x20\x1F\x38\x0D\x94\xA4\x17\xC5\x3C\x78\x84\xDC\x8B\xBB\xD5\xAD\x4F\xD8\xE3\x03\xB8\x02\xC7\x81\x35\x4F\xD8\xB3\xF7\x80\x77\x5F\xE4\x9F\x05\x57\xF5\x5C\x9C\xA4\x7E\x6F\x01\xFE\xDE\xD2\xCD\xC0\x29\x40\xFF\x28\x8B\x3C\x0F\x39\x0A\x18\x7B\x17\x67\x9A\x4C\xA6\x35\x23\x47\x8E\x04\x20\x34\x34\xF4\x73\x60\x34\xE0\x0D\xD8\xD7\x6D\xF5\xEA\x33\x08\xF8\xDC\x41\xBF\x3D\xD5\x00\x3F\x3E\x01\x57\x3B\xD5\x30\x3B\x8C\x86\x8A\xFA\xC7\x01\xBC\x68\xB1\x58\x82\xFC\xFC\xFC\x00\xC8\xCE\xCE\x66\xED\x9A\xB5\x6F\x76\x7B\xB9\xDB\xDE\xC8\xC8\xC8\x66\xA1\xB3\x67\xCF\x02\x10\x1C\x1C\xCC\xB6\x6D\xDB\xB6\xE8\x74\xBA\x54\xFB\x7E\x7B\xFA\xEC\xB3\xCF\xA8\xAB\xAB\xF3\x79\x02\x48\x53\x69\x69\x69\x6A\x71\x71\x31\x87\x0F\x1F\xEE\xEA\x08\x24\x2E\x5A\xD7\xBE\xB1\xB1\xB1\x22\x22\x62\xB5\x5A\x45\x44\xA4\xB2\xB2\x52\x34\x8A\xA6\x24\x25\x25\x45\xEC\xA9\xB4\xB4\x54\x4A\x4B\x4B\x45\x1E\x66\x78\xA9\xAE\xAE\x16\xAB\xD5\x2A\x95\x95\x95\xD2\x92\x52\x52\x52\x04\x98\xAF\x36\x6F\x75\x3A\x6F\x1B\xCF\xCD\xC5\xC3\xE7\x61\x56\x7A\x28\xAB\xD1\x38\x8D\x56\xFB\x72\x81\x20\xA3\xA1\xE2\x61\x1E\x7C\xD0\xF4\x20\x41\xAF\xD7\x03\xB0\x77\xEF\x5E\x00\x86\x0C\x19\x82\x88\x4C\xB2\xB7\x86\xD9\x6C\xA6\xAA\xAA\xAA\x79\x61\x59\x59\x59\x0C\x1A\x34\x88\x92\x92\x12\x76\xEF\xDE\x8D\xD9\x6C\x06\xE0\xFA\xF5\xEB\x98\xCD\x66\x1A\x1A\x1A\x30\x99\x4C\x05\x26\x93\xA9\x40\xA7\xD3\xDD\x04\x56\xE9\x74\xBA\x9B\x36\x5E\xA7\xC0\x0E\x3F\xFC\x77\xFE\x6C\x9A\x64\x32\x99\x0A\x4A\x4B\x4B\xFF\x10\x11\x11\x71\x31\xBD\x28\xE6\x55\x8C\x86\x0A\x45\x41\xA9\xB7\x58\x2C\x22\x22\x12\x11\x11\x21\xB5\xB5\xB5\x22\x22\x92\x95\x95\x25\x36\x0B\x56\x56\x56\x4A\x69\x69\xA9\xA4\xA4\xA4\x34\x5B\xD0\x6A\xB5\x4A\x6D\x6D\xAD\x38\x3B\xB9\x1C\x79\xB5\x63\x58\x9C\xCD\x1A\xB5\xB5\xB5\xA2\xD5\x68\x6B\x2F\x5E\xBC\xD8\x6C\x4D\xAB\xD5\x2A\x3A\x9D\x4E\x1C\xF1\x6C\x16\x2C\x2F\x2F\x17\xAB\xD5\x2A\x16\x8B\x45\xCA\xCB\xCB\x05\x28\xD0\x2C\x78\x7F\x4A\x9F\xA9\xB1\x53\xBB\xD8\xF6\x9E\xD1\x68\xC4\xDF\xDF\x1F\x80\x31\x63\xC6\x34\xAF\x2E\x32\x32\x12\xBD\x5E\xCF\xF0\xE1\xC3\xFF\x53\x8B\x59\x2C\xF8\xFB\xFB\xD3\xA5\x6B\xE0\x50\x5D\xFB\x50\xAB\xBD\x35\x66\x19\x66\xF5\x0C\x0A\x0A\x22\x3B\x3B\x9B\x51\xA3\x46\xE1\xEE\xEE\xCE\xD6\xAD\x5B\x69\xC9\x9B\x35\x6B\x56\xF3\x98\x3B\x77\xEE\xE0\xEE\xEE\x8E\xC5\x62\xA1\xBA\xBA\x1A\x8D\xA2\x71\xD3\x34\x36\x35\xFE\xCE\xE6\x5E\x80\x9E\x3D\x7B\x62\x03\x3B\x64\xC8\x90\x66\xFE\x9C\x39\x73\x50\x14\x85\x8C\xD4\x77\x77\xDB\x78\x8B\x16\x2D\xC2\xCF\xCF\x8F\x75\xEB\xD6\x71\xE4\xEC\x21\xBD\x3D\xC0\x86\x86\x06\x00\x06\x0F\x1E\xCC\xB4\x69\xD3\x00\x38\x77\xEE\xDC\xFF\xF0\xEA\xEB\xFF\x13\x13\xC5\xC5\xC5\xEC\xDF\xBF\x1F\x0F\x0F\x0F\xF2\xF3\xF3\x69\x92\xA6\x14\xEC\xDD\x1B\x1B\x1B\x2B\x80\x00\x62\xE3\x95\x97\x97\x37\xBB\x60\x68\xF0\xB8\xD4\x0E\x3E\x81\xDB\xEC\x83\xC4\xF6\xAE\x06\x44\xB3\x8B\xDD\x5D\x5B\x7F\x65\x1B\x6B\xDB\x22\x9E\x6E\xDE\xFB\x5A\xF2\xEC\x83\xC4\xA6\xCB\xD6\xE7\xAC\x75\xF9\x00\x37\x17\x8F\x1C\xAD\x46\x7B\x05\x90\x76\xDE\x01\x1F\x19\x0D\x15\xE3\x74\x1D\x42\x8B\x9D\xB5\x2E\xD7\x00\x69\xFB\x52\x87\xBD\x80\xB4\xF5\x6C\xFF\xA1\xD1\x50\xD1\x27\x61\xF4\x7B\xA3\xDA\xB4\xF6\xDF\x0D\x88\xBF\x57\xA7\x72\x5F\xCF\xF6\x7B\x00\xF1\x68\xF5\xD2\x4E\x4F\x37\x6F\x33\x20\xEE\xAE\xAD\xBF\x0A\x0D\x1C\xB8\xC4\xD6\x07\x48\x9B\xD6\x7E\x07\x5E\xEB\x35\x25\xD1\xA6\xCF\xC6\xB3\xE9\xF2\xF1\xF0\xFB\x9B\xED\x1D\x10\x4F\x37\xEF\xBD\x41\xFE\xDD\x5F\x57\x8C\x86\x8A\x36\x40\x5B\xC0\x07\x70\x69\x91\x23\x05\xF8\x45\xFD\x07\x63\x05\xEE\x01\x4D\x80\x1B\xE0\xA1\xCA\x3D\x50\xF3\xDC\x7D\xC0\x09\xF0\x54\xF5\x88\x5A\x2D\x69\xED\xF2\x6D\xA3\x2A\x83\x0D\x88\xAA\x1F\xF5\xE9\xA2\x36\x05\xB8\x03\x5C\xD7\xAA\x13\xDE\x03\x6E\xAB\x03\x1A\x55\xC5\xCE\xAA\xB2\x07\x6A\xBB\xAB\xCA\xA1\x82\xF9\xC5\x6E\x11\xF7\xD5\x71\x4D\x76\x0B\x69\x09\xD0\xF6\xB3\x49\xAB\xF2\x5B\x02\x6C\x6C\xA1\xF7\x27\xE0\xC1\xBF\x07\x00\x9D\xD3\x4A\x0C\xA4\x93\x4D\x29\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82"

logos = imgui.CreateTextureFromMemory(memory.strptr(_data),#_data)
