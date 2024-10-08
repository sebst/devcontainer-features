#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="194133626"
MD5="ab15e766ed5896a3ecb51943e6bb411d"
SHA="2f38c87515a62868507b3853301a58d7c5fea3876f0df5017400af6eaff7b01e"
SIGNATURE=""
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="Devcontainer.com Feature: tailscale.com"
script="./entrypoint.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=""
targetdir="."
filesizes="4402"
totalsize="4402"
keep="y"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="718"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  PAGER=${PAGER:=more}
  if test x"$licensetxt" != x; then
    PAGER_PATH=`exec <&- 2>&-; which $PAGER || command -v $PAGER || type $PAGER`
    if test -x "$PAGER_PATH"; then
      echo "$licensetxt" | $PAGER
    else
      echo "$licensetxt"
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -k "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.5.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
  $0 --verify-sig key Verify signature agains a provided key id

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script${helpheader}
EOH
}

MS_Verify_Sig()
{
    GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
    test -x "$GPG_PATH" || GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    test -x "$MKTEMP_PATH" || MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
	offset=`head -n "$skip" "$1" | wc -c | sed "s/ //g"`
    temp_sig=`mktemp -t XXXXX`
    echo $SIGNATURE | base64 --decode > "$temp_sig"
    gpg_output=`MS_dd "$1" $offset $totalsize | LC_ALL=C "$GPG_PATH" --verify "$temp_sig" - 2>&1`
    gpg_res=$?
    rm -f "$temp_sig"
    if test $gpg_res -eq 0 && test `echo $gpg_output | grep -c Good` -eq 1; then
        if test `echo $gpg_output | grep -c $sig_key` -eq 1; then
            test x"$quiet" = xn && echo "GPG signature is good" >&2
        else
            echo "GPG Signature key does not match" >&2
            exit 2
        fi
    else
        test x"$quiet" = xn && echo "GPG signature failed to verify" >&2
        exit 2
    fi
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | sed "s/ //g"`
    fsize=`cat "$1" | wc -c | sed "s/ //g"`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." >&2; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. >&2; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=y
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=
sig_key=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 20 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Tue Oct  8 15:53:21 UTC 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself-2.5.0/makeself.sh \\
    \"--gzip\" \\
    \"--current\" \\
    \"--nox11\" \\
    \"--sha256\" \\
    \"/tmp/tailscale.com.orNCDz0lwx/\" \\
    \"/home/runner/work/devcontainer-features/devcontainer-features/src/tailscale.com/install.sh\" \\
    \"Devcontainer.com Feature: tailscale.com\" \\
    \"./entrypoint.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"y" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\".\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`
	arg1="$2"
    shift 2 || { MS_Help; exit 1; }
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --verify-sig)
    sig_key="$2"
    shift 2 || { MS_Help; exit 1; }
    MS_Verify_Sig "$0"
    ;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    shift 2 || { MS_Help; exit 1; }
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
    shift 2 || { MS_Help; exit 1; }
	;;
    --cleanup-args)
    cleanupargs="$2"
    shift 2 || { MS_Help; exit 1; }
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    export USER_PWD="$tmpdir"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if test -t 1; then  # Do we have a terminal on stdout?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0 >&2
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 20 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 20; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (20 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
‹ qUgí;ïsÛ6²ùjıˆâ©íœ)YwÔqóÛ½ó4µ2¶Ü^æ½»DBŸH‚@ËÊ©ÿûí 	Ò”cÇI^oùAI`±¿w±uº,Qb‘ò0Q9}ò5®¸ö_¾ÄïŞşË¾ïíïëo¼^ìí<éííïôv_î¾|ï{{¯^ì>!;O¾Á•IE "²$abõ¸€û³ÛŞ[ZŠïÿëÙÓn&Ew& WÄ» #*§Äó
>#¦Ÿxœ0!Øu¨ğg¦lLÃ'ÜøhÄ„¹ÉÉT«Åü)'p‘ã“_gÃÃÓ³“óÎÑà‚O7Êä'FU&XŸ( )}±ÏcgÄŠk£å¤]™ÔnuºaB"ĞçÖ“ÇëÖ«Ó­pÏaİ·³ÿŞ«½šı¿zµ³ÿhÿÿÙößrTË³jÅÄ£Mş¹í¿Yd_Óş!úïÔì·ãíÿÙ?Ú>Xå3rÄÓ…'SE6ı-2Ì5œ&>ù^ÿ68¿€qïÿî½}†î@†ã‰>ysqì½ğ"šIÖz#‡ÓPé‹0U$`ŠùJ5eÄÏÀ“$Šğ”	ªÂdBäB*ošÄjD Ô÷¹p¨â ƒ*2¸ØÄçÉ"ÀÙiµÀñe-˜yEf)0XÌMS†À	%1…¯q–ø8Ñ@›0ÀÍG…ÜÂT 2âJñ˜ğ±…Şp›H»<%
tÆ§
&¤T¨F$àó$â4€L&Š°$ 0YJØ5ó3Mé”Fc˜l¸Òi!*›[ä_­5`¬b)éõ-«*œŠÂ$»&A(•àÛäŠ		˜v¥ÔŸÑIÉÄ€Bh¿1"X´ )Û9SM/³‘%4fz~—)¿Ë¥ƒ•ù;o Aà2Á¡zdeÙ± Î Š‚‘93Â3EæÀœg%h–‹™šò€Ì‘SE1’IÀ7Gtt£ [™EÊpõ¹JÃmÍE|®U`*Ã©WT„t1I(à‘ò4‹P Û$[."s
Ğ2ßgR³–\´Û­µ_OÎ/Ngú÷»Ã£Ÿÿz2|ÿîDß¾~øùäıû€<#ƒ˜9æ‚ĞTy%AîFÒŒ¾x1<ùåhøöÃÅğğ|x0¦pÓÎK$²ˆ½aĞÏ4
[kÃsXú ½ş/ı£ïë€¢?Ú­Öšòh¯ëmàjkmÍ¼]f‰ù±Ö~ø>ŸëŸ:cnÃÛ,M¹@İTôƒXz†ğ^>IêÃJÀ¯ÿ&Şø†2üãd=.üìÆ»œİÀ|’d1&  ;9e`z…`:¨‡>J‡PE*‚ìk¸Ä#§Ç}ı4D(£pÖè@ÿ6YgÒ!í€Bš´·I{ÒÉ ½•O·‚üƒl˜}’cjW3İ ÕB“E¼÷}ggï&À£ÁñÉÙá/'ıÂ—Ôp³+ÔÁ ¬0QÂ»|sy6¼tÀÁpˆB*¹æÀ´Í0p »¾:@éÔ¹Ï¬vœ[ÕXËFY¢²%Èe™0,?r&K•]³€kíĞŠoFiU0bÕ«ãçıÑ&Oè}© kk®ÂfÖks@iÔêcë™ÁãPULŒË¼ÔÑCúÖ™1MÉD‚ıø(d*ØSÒ w1|lgVü¸úKM2Ùİ!wrÂÙu*H‰²±OÚ»çmòc7`Wİ$‹"‡úšK°ÕÈ®ŠØ„ú‹
µÚX×Œ2—BA)ê›Oñìë3ëX£Fz=²ù8 Ù‚muJmñ>¢Â8‡ºâj	€`àè§­®vÈé˜,x±‚5„Åƒ„À†¶míà!”Ãê0¦s^[­u%çAà Œÿ±Z^®(V‰«²NE^:şÆa¢¶>Ónê–w'[Ê—9>yszxv×e¬£lX¦§ÁdoGó3Ìx…¬^~=QÎÅ WT,š}Ş'¸~/2^}=2À”WK %`QI‰+Ü‡p¼à‚Uw'À™i¼Cû~„MÀÙ„YÌe³xš‰*/úæájl-3Á¸\Îh(Yr® ñ
Í‚‚ÊôOë×Ï-r+=û·õ¨3H~ï#“÷'‡çÀ½M“áVP]B,ß¸G¼ ³UÊª‘câıMÂå6ì„Bª|"ç¡ò§,°óa ³Ï&SØìîìö:×y ”®0`#T±tÉÜ(µ‘¥½í‡PoDq§O³PNáëÿÚ3–†ÉİÑT©Tö»İI¨¦Ù¨Zƒr~…RfLv÷¿µûpW¸»sWµnæÑ”}“*Œğ!P¹ğw‘¿©P$ã&JÛ’ƒıZZV™¸Èât¸h8ì#VÇæ®æ÷5±S7 6°ìÏ€äö\‚Ş†æm8XB¹?[,iS~.>¢‚.yÊ’˜&¯èRÒdÂcº!ìpåÒx˜Ñv’AÄ£’NÁ9°8¼.‘2ïî?:!Æô#O<½Ú½”·`œzÍ°&R …•à‰|×D>JØz{à{Ó¥Œ˜cˆù»Úº8²{;Uiš;ŠÚ:*‹G›3|r¡rè– ä½8ô÷M Øˆ»QÒ{ÙÙ»|*üé?¨ˆ—˜‘Ò+	Ğ7@2	à{BE8êcëzEnlo.R?Î}ºYnÿ—
¾´ß`P.c~™•hA‰}¾3¦é¬’}r©b*f¬âáÍ"›„×9@cïL‘‹S/‡4vÓ‚œ…×ƒ,“ÃI&LÖ„‚ù*ZôÛœdâ*ô™ì”!–`-<!fP?ØYEÑâuÅÃàVw©\Ré;Aëç;B1a.`[Cüòq$U¶\Æş·Øz¤S®¸ã•Íı¡H¹î¿eÒçÁñ Oæ2zíŞËEÂ#>Y¼&¿'4ÅWººŒ‹õ§cl`×ËÒ<osH)¶-ëcZLÊ*ç6j.vp~V4"”X˜<rt¢çÊ¼AU§åªnè†çj‘2©¬ò‘İ¿ë•ŞV7õ°­¼ººö¨Ì›‹ã­<·÷°msÁHo·³[4~°Ò•«Unui]“,
ò±dÌ3l}©|1Ü)À>Ä-·>B.Ñ¿b¶L¦ƒ¸­†×²ÎõMûÂË«ßM‚^¡»V©Ö<J’ópÒ¸šá©'W¡S1hLı<Ä» åüâN< =È|õkow%)4M¥±TW~‹IŠK6°ÜÔ¥İB†Ñmõå
q1‚M
—&
U+û~&¢m2”wÔö¢Ã	#qÇ‘Ö‚ù„©l)µa ¦ãü¹©Ò+°ôÃ û£Ëó·­BŸq…¦¢µÖÖo½±¼xøë¢¢„k­¤ßz¿oàµ5Qá×¬ŒSÁ6^qhÀ6¼Xˆ6øqa–DËÏû¤ØR•v«Ê,˜UÓA| oæÙ0¤E0<¹~ĞèçÛJĞh7áöfìØÑƒËáÁú¦&	;m@[{„-²\»şÚR¿~~„u×OĞîÓ$á
¢…ıw	³NeLgŒÈL0ÓâÔá,Üm ²áH¦ºué°iÈ¤Â†kš©~ñt=§§ÎÛXŞí£¡1İº¿‹YÓ.ÜÆ2Bˆzš÷¸t“Õ˜t¾Æê‡Ë³‹ËwïçÃ“ãƒ¢Y‰Wû0Û2!o™—Æ–&Ÿ_šíå÷rKw±ÌóÕ¥Ñ‘£)ógdú`Ê3ºçè@®ŸO™VJ&áKŠ~v‘óF¨ö˜ŸÒÓ&íE–ß-äê°´ÈuÆª)£É’L0¬gğ3ªPUEïÕİ$š«‹¥¶IÂz|ä‚It~Ï ‰3DiP˜p[@çÕl¨Ú§;ßfÒáäÏ÷£Æ”§EßÎ×ä7°5İÅ/¤•k@ğºX¾È??}'ÕüLnNY¯"`»¦·^“|÷ùŸ–i­ÜñFàË¢ÖĞ¤;¦Ğ —´áX/¹RÍtxµ„ıÆÀü±Ä¥Ğù`ş•‚¦>\IVš>·ÑÌÃ(2³a[¹N\e…Ô}õL–ŒpÂêí˜=¿õµ‰°–“ÕAº,ÓsƒPİıÜ@ÂúÎ£<íB/(bt¶`	HT7ßuŠ€ú‡'Âğ”JÛ™üg‘â!‚â‰Œó	®!…P}wÂ§}Í3ÁÍåÛí» \?<…d‚Ioñ¹xDrµ³åáò¸ÈhaOß˜S[ÈG@6ç±;FÎôv7…3<Ùƒ:dá™˜fÑ1øo“ÔD?ãñQ;ğ¿jg¸sØ:ÙÇó$ vn}5‘YÁ§È!ü(Xíäl@®C83ÀLö4“ƒmÿXHQ¹Šû<Q,¸DÀI×›öİw Ğ%¶‡ŠÔšêD7/>»CÚ6Í1şôi0Õp¤¤
üŒ×‡”5$/úåI°Pïõ B9AÂ^A¦î¢aíRÚ£~cHˆ·Â”Ï1¯=<ûp>!¸¸<Ö¿ÄË¶Ğìİì«>CÏhWr\™¼1Ç½9‡VæÎİæâP7K†Ù²n½)[ÆT«–.ƒå »r@@p®œÌï7<>#ÎuB×»¸›Ã|ˆÊ†Ùmø¹ãÀã|¸zì :1©µ`®èš¼]t3n<P™¥š]„|#å.„¿×'«}Ø®ÜÒiºõlT¬Ì”c_ÖßğH|YîB6”“¶ÍÃ¼wW3B)Ü‡&dĞÔï`×ÚyÙÓ?Î†'gÇ	OtJN}šİ½¶[œÑÉ¶YO:MÒIó¹¢uÔ!}¨p¢¹@hnx‘ï‰¼™$Y:±‰€®şâVíºUL‰gA(`×L</æ;ÀÓ×DŸó—S*X7ox:µ*	¶aÈ°Ûe›îŞ/yîPéc…©$ÖÖ•Jï!P£Pª¬bÌø)€ß•àÃ±x‰C:sº8qÍ2áAÔ%œŠ˜‹È¶†ÎMf;Gë1Wòì«NU5‚P¹Fû°Êı•ŠºROËl}%í5+ªuìµ1á Ú3š@í«ˆØò4şQe^.4Åãşª6ÈäÓhEA+ÒT/2Óf¨Û</H„ß^¦ [á™z»^ö(yáy õFS~_¡:‚Áéíf\J^»¸Ü‰GUÂƒdÜH8<we»÷T›Ur·6ª³êÌø
œ¨!WŒ{'ÔMV”¥´‡âN~4†2ÔdÅñI‰»ú*ä™._£¬E€0Öağ¾„"îÚ#–ğÌR§Äsb(¡ğpB<ñå4aåR8y4SÜ†.R»v9½€–ö¹Ü7ì7ıÇFö›Wøg<Çª¢6$?pİÙ¤yÑÙäVMWĞm×¼uˆö¶HĞtVC‚ÀS[6;ùlüõ¡ó¼‹&KBµXßÈ×Lk˜Ç·Š¤Ÿ©,õ` ·â0wre¨ç¯W;âc’Î°L:K™Ø*œıOS)Ñ®ÍüÕÃ°Hÿë¨{ÛPpz©&™Ï<°ÎtÆÔ á{&ß2à†TV
{¯ª/¼U¦ÄtZÁ˜Wèÿåì -ò®Ò¤[Aû†˜.NV½J—ƒ:ğaİE&ñ‰{v,èíí¿|ñı~oo·İ°HõŸ3üëâxöè3°¦¤(6kåªoè›ÿNSÙ©˜j *ö”¼åhiºL¢“³W)÷2£E^ÜèÛMÛ|AVŞÜN–RÉR½‹5ÛySï1A¤:4ì–ş÷Ùãÿq¯Çëñz¼¯Çëñz¼¯Çëñz¼ş\ÿè0× P  