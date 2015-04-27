function str = num2words(num,opts,varargin)
% Convert a number to a string with the English name of the number value (GB/US).
%
% (c) 2015 Stephen Cobeldick
%
% Convert a numeric scalar into a string giving the number in English words,
% e.g. 1024 -> 'one thousand and twenty-four', exactly as it would be spoken
% by a person: very handy for converting to text or computer-generated voice!
%

%
% ### Input Wrangling ###
%
assert(isnumeric(num)&&isscalar(num),'First input <num> must be a numeric scalar.')
assert(isreal(num),'First input <num> must not be a complex value. Value: %g%+gi',num,imag(num))
%
% Default option values:
dfar = struct('case','lower', 'type','decimal', 'scale','short',...
    'comma',true, 'hyphen',true, 'ae',false, 'pos',false, 'trz',false,...
    'order',0, 'sigfig',0,... % Names in cell arrays, as per post-parsing:
    'subunit',{{'Cent','Cents'}}, 'unit',{{'Dollar','Dollars'}});
%
% Check any supplied option fields and values:
switch nargin
    case 1 % no options
        dfar.isf = false;
        dfar.mny = false;
    case 2 % options in a struct
        assert(isscalar(opts)&&isstruct(opts),'Second input <opts> can be a scalar struct.')
        dfar = n2wOptions(dfar, opts);
    otherwise % options as <name-value> pairs
        dfar = n2wOptions(dfar, struct(opts,varargin{:}));
end
%
% ### Order & Significant Figures ###
%
dfar.isf = ~isempty(dfar.isf) && dfar.isf;
%
if isfinite(num)
    %
    mag = floor(log10(abs(double(num))));
    mag(isinf(mag)) = -1;
    %
    if dfar.isf % sigfig
        sgf = dfar.sigfig;
        odr = mag + 1 - sgf;
    else % order
        odr = dfar.order;
        sgf = mag + 1 - odr;
    end
    %
else % Infinity or NaN
    %
    sgf = 0;
    odr = 0;
    %
end
%
% ### Convert Numeric to Words ###
%
frc = [];
%
if sgf<1 % round one digit to a particular order
	%
	raw = sprintf('%+.0f',num/10^odr);
	%
	if strcmp(raw,'NaN')
		str = 'Not-a-Number';
		dfar.pos = false;
	elseif strcmp(raw(2:end),'Inf')
		str = 'Infinity';
	else
		[str, frc, odr] = n2wParse(dfar, odr, odr, raw(2:end)-48);
	end
	%
elseif isfloat(num)
	%
	tmp = min(sgf,6+9*isa(num,'double'));
	raw = sprintf('%#+.*e', tmp-1, num);
	%
	if strcmp(raw,'NaN')
		str = 'Not-a-Number';
		dfar.pos = false;
	elseif strcmp(raw(2:end),'Inf')
		str = 'Infinity';
	else % scientific notation to vector
		vec = [2,4:2+tmp];
		idz = strcmp('0',raw(2));
		pwr = sscanf(raw(3+tmp:end),'e%d')-idz;
		tmp = odr + (dfar.isf && pwr>mag);
		%
		[str, frc, odr] = n2wParse(dfar, pwr, tmp, raw(vec(1+idz:end))-48);
		%
	end
	%
else % int | uint
	%
	cls = class(num);
	dgt = sscanf(cls, '%*[ui]nt%u');
	pfx = {'X','X','%h','%h','%','%l'}; % {2,4,8,16,32,64} bit
	%
	tmp = max(0,odr);
	raw = sprintf([pfx{log2(dgt)},cls(1)], num/10^tmp);
	%
	ngv = strncmp(raw,'-',1);
	pwr = numel(raw) + tmp - 1 - ngv - (mag<0);
	tmp = odr + (dfar.isf && pwr>mag);
	%
	[str, frc, odr] = n2wParse(dfar, pwr, tmp, raw(1+ngv:end)-48);
	%
end
%
% ### Money or Ordinal ###
%
if dfar.mny
    % Select singular/plural form of unit/subunit currency name:
    fun = @(s,c) sprintf('%s %s',s,c{2-strcmp(s,'One')});
end
%
switch dfar.type
    case 'cheque'
        if odr>=0 || ~(dfar.trz || any(frc)) % Suffix with 'Only':
            str = sprintf('%s Only', fun(str,dfar.unit));
        else % Always include leading units, even if they are zero:
            str = sprintf('%s and %s', fun(str,dfar.unit),...
                fun(n2wCents(dfar,frc,odr),dfar.subunit));
        end
    case 'money'
        if odr>=0 || ~(dfar.trz || any(frc)) % Only the units:
            str = fun(str,dfar.unit);
        elseif strcmp(str,'Zero') % Only the subunits:
            str = fun(n2wCents(dfar,frc,odr),dfar.subunit);
        else % Mixed units and subunits:
            str = sprintf('%s and %s', fun(str,dfar.unit),...
                fun(n2wCents(dfar,frc,odr),dfar.subunit));
        end
    case 'ordinal'
        expr = {'(r|x|n|d|ro)$','One$','Two$','ree$','ve$','ht$','ne$','ty$'};
        repstr = {'$1th','First','Second','ird','fth','hth','nth','tieth'};
        str = regexprep(str,expr,repstr,'once','ignorecase');
end
%
% ### Sign and Case ###
%
if strncmp(raw,'-',1)
    str = ['Negative ',str];
elseif dfar.pos
    str = ['Positive ',str];
end
%
switch dfar.case
    case 'lower'
        str = lower(str);
    case 'upper'
        str = upper(str);
    case 'sentence'
        str(2:end) = lower(str(2:end));
end
%
end
%----------------------------------------------------------------------END:num2words
function dfar = n2wOptions(dfar, opts)
% Options check: only supported fieldnames with suitable option values.
%
fnm = fieldnames(opts);
idx = ~cellfun(@(f)any(strcmpi(f,fieldnames(dfar))),fnm);
if any(idx)
    error('Unsupported field name/s:%s\b',sprintf(' <%s>,',fnm{idx})) %#ok<SPERR>
end
% Logical options:
dfar = n2wLgc(dfar,fnm,opts,'ae');
dfar = n2wLgc(dfar,fnm,opts,'pos');
dfar = n2wLgc(dfar,fnm,opts,'trz');
dfar = n2wLgc(dfar,fnm,opts,'comma');
dfar = n2wLgc(dfar,fnm,opts,'hyphen');
% String options:
dfar = n2wStr(dfar,fnm,opts,'case','lower','upper','title','sentence');
dfar = n2wStr(dfar,fnm,opts,'scale','long','short','peletier','rowlett');
dfar = n2wStr(dfar,fnm,opts,'type','decimal','ordinal','highest','cheque','money');
% Currency Names:
dfar.mny = any(strcmpi(dfar.type,{'cheque','money'}));
dfar.order = -2*dfar.mny;
dfar = n2wUni(dfar,fnm,opts,'unit');
dfar = n2wUni(dfar,fnm,opts,'subunit');
% Precision:
dfar.isf = [];
dfar = n2wDgt(dfar,fnm,opts,'sigfig');
dfar = n2wDgt(dfar,fnm,opts,'order');
dfar.isf = ~isempty(dfar.isf) && dfar.isf;
%
end
%----------------------------------------------------------------------END:n2wOptions
function idx = n2wCmpi(fnm,str)
% Options check: throw an error if more than one fieldname match.
%
idx = strcmpi(fnm,str);
if sum(idx)>1
    error('Repeated field names:%s\b',sprintf(' <%s>,',fnm{idx})); %#ok<SPERR>
end
%
end
%----------------------------------------------------------------------END:n2wCmpi
function dfar = n2wLgc(dfar, fnm, opts, str)
% Options check: logical scalar.
%
idx = n2wCmpi(fnm,str);
if any(idx)
    tmp = opts.(fnm{idx});
    assert(islogical(tmp)&&isscalar(tmp),'The <%s> value must be a scalar logical.',str)
    dfar.(str) = tmp;
end
%
end
%----------------------------------------------------------------------END:n2wLgc
function dfar = n2wStr(dfar, fnm, opts, str, varargin)
% Options check: string.
%
idx = n2wCmpi(fnm,str);
if any(idx)
    tmp = opts.(fnm{idx});
    if ~ischar(tmp)||~isrow(tmp)||~any(strcmpi(tmp,varargin))
        error('The <%s> value must be one of:%s\b',str,sprintf(' ''%s'',',varargin{:}));
    end
    dfar.(str) = lower(tmp);
end
%
end
%----------------------------------------------------------------------END:n2wStr
function dfar = n2wDgt(dfar, fnm, opts, str)
% Options check: numeric scalar (significant figures or order).
%
idx = n2wCmpi(fnm,str);
if any(idx)
    assert(isempty(dfar.isf),'You can only specify one of <order> or <sigfig>.')
    dfar.isf = strcmp(str,'sigfig');
    tmp = opts.(fnm{idx});
    assert(isnumeric(tmp)&&isscalar(tmp),'The <%s> value must be a scalar numeric.',str)
    assert(isreal(tmp),'The <%s> value must not be complex: %g%+gi',str,tmp,imag(tmp))
    assert(~dfar.isf||(tmp>=1),'The <%s> value must not be zero or negative: %g',str,tmp)
    dfar.(str) = double(tmp);
end
%
end
%----------------------------------------------------------------------END:n2wDgt
function dfar = n2wUni(dfar, fnm, opts, str)
% Options check: currency unit or subunit name.
%
idx = n2wCmpi(fnm,str);
if any(idx) && dfar.mny
    tmp = opts.(fnm{idx});
    assert(ischar(tmp)&&isrow(tmp),'The <%s> value must be a string (currency name).',str)
    tmp = regexp(tmp,'\|','split');
    assert(~isempty(tmp{1}),'The <%s> value string does not define a currency name.',str)
    assert(numel(tmp)<3,'The <%s> value string may contain up to one "|" character.',str)
    if isscalar(tmp) % invariant
        dfar.(str) = tmp([1,1]);
    elseif isempty(tmp{2}) % regular
        dfar.(str) = strcat(tmp(1),{'','s'});
    else % irregular
        dfar.(str) = tmp;
    end
end
%
end
%----------------------------------------------------------------------END:n2wUni
function str = n2wCents(dfar, frc, odr)
% Create the currency subunit string (defined as 1/100 of currency unit).
%
idx = numel(frc)>1 && frc(1)==0;
dfar.mny = false;
dfar.type = 'decimal';
str = n2wParse(dfar, 0+~idx, 2+odr, frc(1+idx:end));
%
end
%----------------------------------------------------------------------END:n2wCents
function [str, frc, odr] = n2wParse(dfar, pwr, odr, vec)
% Convert a numeric vector of digits to english number names/words.
%
if dfar.trz % Pad <vec> with trailing zeros:
    vec(1+end:1+pwr-odr) = 0;
elseif isempty(vec)
    frc = [];
    str = 'Zero';
    return
else % Remove trailing zeros from <vec>:
    chg = [find(vec,1,'last'),0];
    vec = vec(1:chg(1));
    odr = 1+pwr-numel(vec);
end
%
stP = {' Zero',' One',' Two',' Three',' Four',' Five',' Six',' Seven',' Eight',' Nine'};
%
% Handle special cases (zero or decimal-fraction only):
if pwr<0 && (dfar.trz || any(vec))
    frc = [zeros(1,0-1-pwr),vec];
    if dfar.mny && ~isempty(dfar.subunit)
        str = 'Zero';
    else
        str = ['Zero Point',stP{1+frc}];
    end
    return
elseif isempty(vec) || vec(1)==0
    frc = vec(2:end);
    if isempty(frc) || dfar.mny || odr>=0
        str = 'Zero';
    else
        str = ['Zero Point',stP{1+frc}];
    end
    return
end
%
% Define the magnitude names:
switch dfar.scale
    case 'short'
        stS = n2wShort;
    case 'long'
        stS = n2wShort;
        stS(2:2:end) = stS(1:floor(numel(stS)/2));
        stS(1:2:end) = {'Thousand'};
    case 'peletier'
        stS = n2wPeletier;
    case 'rowlett'
        stS = n2wRowlett;
    otherwise
        error('Well, this comes as a surprise... this scale is not recognized!')
end
%
stS = [{'','Thousand','Million'},stS];
stT = {'','Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety'};
stO = {'One','Two','Three','Four','Five','Six','Seven','Eight','Nine','Ten','Eleven',...
    'Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Nineteen'};
%
% Power of each digit, determine suffix group based on this:
rdo = pwr:-1:odr;
grp = floor(rdo/3);
% Separate the digits into a groups matrix and decimal-fraction vector:
idGrp = grp>=0 & (grp==grp(1) | ~strcmp(dfar.type,'highest'));
out = cell(11,1+grp(1));
val = zeros(3,1+grp(1));
val(1+rdo(idGrp)) = vec(idGrp);
frc = vec(~idGrp);
% Determine the indices of all required words:
idHun = val(3,:)>0;  % hundreds
idTen = val(2,:)>1;  % tens
idTee = val(2,:)==1; % teens
idOne = val(1,:)>0 | idTee; % teens|ones
idTTO = idTen | idOne; % tens|teens|ones
% Determine magnitude groups:
idAny = any(val,1);  % any values in a magnitude group
idTra = [false,idAny(1:end-1)]; % ...with trailing values.
% Determine comma positions:
idCom = idTra & dfar.comma;
if numel(idCom)>1 % comma iff hundreds value
    idCom(2) = idCom(2) && idHun(1);
end
% Groups requiring separation:
idSep = idAny;
idAnd = idHun;
if strcmp(dfar.scale,'long')
    idSep(1:2:end-1) = idAny(1:2:end-1) | idAny(2:2:end);
    idAnd(1:2:end-1) = idAnd(1:2:end-1) | idAny(2:2:end)&idTTO(1:2:end-1);
    idCom(4:2:end)  = ~idAnd(3:2:end-1) & idCom(4:2:end);
end
idAnd(1) = idAnd(1) || idTTO(1)&&any(idAny(2:end));
% Insert the required words and punctuation into a cell array:
out(11,idHun) = stO(val(3,idHun));
out(10,idHun) = {' Hundred'};
out(9,idHun&idTTO) = {' '};
out(8,idAnd&idTTO&~dfar.ae) = {'and '};
out(7,idTen) = stT(val(2,idTen));
out(6,idTen&idOne) = {char(32+13*dfar.hyphen)};
out(5,idOne) = stO(val(1,idOne)+10*idTee(1,idOne));
out(4,[false,idSep(2:end)]) = {' '};
out(3,idSep) = stS(idSep);
out(2,idCom) = {','};
out(1,idTra) = {' '};
% Add any decimal fraction digits:
if ~isempty(frc)
    switch dfar.type
        case {'decimal','ordinal'}
            out{4,1}   = [' Point',stP{1+frc}];
        case 'highest'
            out{4,end} = [' Point',stP{1+frc},char(32*ones(1,pwr>2))];
    end
end
% Concatenate all substrings to create the output string:
str = [out{end:-1:1}];
%
end
%----------------------------------------------------------------------END:n2wParse
function stS = n2wShort
% Derived from the work of John Conway, Allan Wechsler, Richard Guy, and Olivier Miakinen.
%
stS = {'Billion','Trillion','Quadrillion','Quintillion','Sextillion','Septillion',...
'Octillion','Nonillion','Decillion','Undecillion','Duodecillion','Tredecillion',...
'Quattuordecillion','Quindecillion','Sedecillion','Septendecillion',...
'Octodecillion','Novendecillion','Vigintillion','Unvigintillion','Duovigintillion',...
'Tresvigintillion','Quattuorvigintillion','Quinvigintillion','Sesvigintillion',...
'Septemvigintillion','Octovigintillion','Novemvigintillion','Trigintillion',...
'Untrigintillion','Duotrigintillion','Trestrigintillion','Quattuortrigintillion',...
'Quintrigintillion','Sestrigintillion','Septentrigintillion','Octotrigintillion',...
'Noventrigintillion','Quadragintillion','Unquadragintillion','Duoquadragintillion',...
'Tresquadragintillion','Quattuorquadragintillion','Quinquadragintillion',...
'Sesquadragintillion','Septenquadragintillion','Octoquadragintillion',...
'Novenquadragintillion','Quinquagintillion','Unquinquagintillion',...
'Duoquinquagintillion','Tresquinquagintillion','Quattuorquinquagintillion',...
'Quinquinquagintillion','Sesquinquagintillion','Septenquinquagintillion',...
'Octoquinquagintillion','Novenquinquagintillion','Sexagintillion',...
'Unsexagintillion','Duosexagintillion','Tresexagintillion',...
'Quattuorsexagintillion','Quinsexagintillion','Sesexagintillion',...
'Septensexagintillion','Octosexagintillion','Novensexagintillion',...
'Septuagintillion','Unseptuagintillion','Duoseptuagintillion',...
'Treseptuagintillion','Quattuorseptuagintillion','Quinseptuagintillion',...
'Seseptuagintillion','Septenseptuagintillion','Octoseptuagintillion',...
'Novenseptuagintillion','Octogintillion','Unoctogintillion','Duooctogintillion',...
'Tresoctogintillion','Quattuoroctogintillion','Quinoctogintillion',...
'Sexoctogintillion','Septemoctogintillion','Octooctogintillion',...
'Novemoctogintillion','Nonagintillion','Unnonagintillion','Duononagintillion',...
'Trenonagintillion','Quattuornonagintillion','Quinnonagintillion',...
'Senonagintillion','Septenonagintillion','Octononagintillion','Novenonagintillion',...
'Centillion','Uncentillion'};
%
end
%----------------------------------------------------------------------END:n2wShort
function stS = n2wPeletier
% Derived from the short scale.
%
stS = {'Milliard','Billion','Billiard','Trillion','Trilliard','Quadrillion',...
'Quadrilliard','Quintillion','Quintilliard','Sextillion','Sextilliard',...
'Septillion','Septilliard','Octillion','Octilliard','Nonillion','Nonilliard',...
'Decillion','Decilliard','Undecillion','Undecilliard','Duodecillion',...
'Duodecilliard','Tredecillion','Tredecilliard','Quattuordecillion',...
'Quattuordecilliard','Quindecillion','Quindecilliard','Sedecillion','Sedecilliard',...
'Septendecillion','Septendecilliard','Octodecillion','Octodecilliard',...
'Novendecillion','Novendecilliard','Vigintillion','Vigintilliard','Unvigintillion',...
'Unvigintilliard','Duovigintillion','Duovigintilliard','Tresvigintillion',...
'Tresvigintilliard','Quattuorvigintillion','Quattuorvigintilliard',...
'Quinvigintillion','Quinvigintilliard','Sesvigintillion','Sesvigintilliard',...
'Septemvigintillion','Septemvigintilliard','Octovigintillion','Octovigintilliard',...
'Novemvigintillion','Novemvigintilliard','Trigintillion','Trigintilliard',...
'Untrigintillion','Untrigintilliard','Duotrigintillion','Duotrigintilliard',...
'Trestrigintillion','Trestrigintilliard','Quattuortrigintillion',...
'Quattuortrigintilliard','Quintrigintillion','Quintrigintilliard',...
'Sestrigintillion','Sestrigintilliard','Septentrigintillion',...
'Septentrigintilliard','Octotrigintillion','Octotrigintilliard',...
'Noventrigintillion','Noventrigintilliard','Quadragintillion','Quadragintilliard',...
'Unquadragintillion','Unquadragintilliard','Duoquadragintillion',...
'Duoquadragintilliard','Tresquadragintillion','Tresquadragintilliard',...
'Quattuorquadragintillion','Quattuorquadragintilliard','Quinquadragintillion',...
'Quinquadragintilliard','Sesquadragintillion','Sesquadragintilliard',...
'Septenquadragintillion','Septenquadragintilliard','Octoquadragintillion',...
'Octoquadragintilliard','Novenquadragintillion','Novenquadragintilliard',...
'Quinquagintillion','Quinquagintilliard','Unquinquagintillion'};
%
end
%----------------------------------------------------------------------END:n2wPeletier
function stS = n2wRowlett
% Derived from the work of Russ Rowlett and Sbiis Saibian.
%
stS = {'Gillion','Tetrillion','Pentillion','Hexillion','Heptillion','Oktillion',...
'Ennillion','Dekillion','Hendekillion','Dodekillion','Trisdekillion',...
'Tetradekillion','Pentadekillion','Hexadekillion','Heptadekillion','Oktadekillion',...
'Enneadekillion','Icosillion','Icosihenillion','Icosidillion','Icositrillion',...
'Icositetrillion','Icosipentillion','Icosihexillion','Icosiheptillion',...
'Icosioktillion','Icosiennillion','Triacontillion','Triacontahenillion',...
'Triacontadillion','Triacontatrillion','Triacontatetrillion','Triacontapentillion',...
'Triacontahexillion','Triacontaheptillion','Triacontaoktillion',...
'Triacontaennillion','Tetracontillion','Tetracontahenillion','Tetracontadillion',...
'Tetracontatrillion','Tetracontatetrillion','Tetracontapentillion',...
'Tetracontahexillion','Tetracontaheptillion','Tetracontaoktillion',...
'Tetracontaennillion','Pentacontillion','Pentacontahenillion','Pentacontadillion',...
'Pentacontatrillion','Pentacontatetrillion','Pentacontapentillion',...
'Pentacontahexillion','Pentacontaheptillion','Pentacontaoktillion',...
'Pentacontaennillion','Hexacontillion','Hexacontahenillion','Hexacontadillion',...
'Hexacontatrillion','Hexacontatetrillion','Hexacontapentillion',...
'Hexacontahexillion','Hexacontaheptillion','Hexacontaoktillion',...
'Hexacontaennillion','Heptacontillion','Heptacontahenillion','Heptacontadillion',...
'Heptacontatrillion','Heptacontatetrillion','Heptacontapentillion',...
'Heptacontahexillion','Heptacontaheptillion','Heptacontaoktillion',...
'Heptacontaennillion','Oktacontillion','Oktacontahenillion','Oktacontadillion',...
'Oktacontatrillion','Oktacontatetrillion','Oktacontapentillion',...
'Oktacontahexillion','Oktacontaheptillion','Oktacontaoktillion',...
'Oktacontaennillion','Enneacontillion','Enneacontahenillion','Enneacontadillion',...
'Enneacontatrillion','Enneacontatetrillion','Enneacontapentillion',...
'Enneacontahexillion','Enneacontaheptillion','Enneacontaoktillion',...
'Enneacontaennillion','Hectillion','Hectahenillion','Hectadillion'};
%
end
%----------------------------------------------------------------------END:n2wRowlett