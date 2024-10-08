#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1386870505"
MD5="e4ed2ac84b44a8edc2cfefbf4fc56411"
SHA="aeffc5a3c10bbe83df60361e2c1bfe68f7fc9ef92b0750f40290bb0906b6e037"
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
filesizes="4403"
totalsize="4403"
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
	echo Date of packaging: Tue Oct  8 15:52:19 UTC 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself-2.5.0/makeself.sh \\
    \"--gzip\" \\
    \"--current\" \\
    \"--nox11\" \\
    \"--sha256\" \\
    \"/tmp/tailscale.com.Upkc3VWwtk/\" \\
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
‹ 3Ugí;ïsÛ6²ùjıˆâ©íœ)YwÔqóÛ½ó4µ2¶Ü^æ½»DBŸH‚@ËÊ©ÿûí 	Ò”cÇI^oùAI`±¿w±uº,Qb‘ò0Q9}ò5®¸ö_¾ÄïŞşË¾ïíïëo¼^ìí<éííïôv_îî½zñd§Ÿ/'ßàÊ¤¢PY’0±z\ÀıÙmï--Å÷Èõìi7“¢;
P„+â]•Sây	O‡Ó¿…O<N˜ì:Tø3S6¦a„¿îG|4bÂÜd‰dªÕbş”“¸ÈñÉ¯Gƒ³ááéÙÉyçhğÁ§åò£*¬O€”>XÇç±3bÅµÑòÒ®Lj·:İ0¡FèsëÉãuëÕéV¸ç°îÛÙïÕ^Íş_½êí<Úÿ¶ı·Õò¬Z1ñh“nûoÙ×´ˆş;5ûßííì¿z´ÿodÿhû`•ÏÈO"œLÙô·È0×ršøä;rx9üÛàüÆ]¼;ş»÷6ôºw@C&úäÍÅ±÷Â;Šh&YëŒNCI¤/ÂT‘€)æ+IÔ”?O’(ÂS&¨
“	‘©X¼Mh«yHPßç"À¡ŠªÈàbCŸ'Wˆ Od§ÕÇC<–µ`æa™¥xÀ`14M'”Ä¾ÆYâãDmÂ 7> pSÈˆ+ÅcÂÇzÃm"íò”(ĞŸ*˜R¡B‘€Ï“ˆÓ ~0™l(Â’ Àd)a×ÌÏ4¥Sa²áJ§…¨ln‘µÖ€±Š¥¤×·¬ªp*
“ìš¡T‚o“+&$`nØ•RF'%; 
¡ıÆˆ`Ñ‚p¤läL5½@ÎF–Ğ˜mèù]¦ü.—fT2äï8¼M€Ë‡ê‘•eÇ8(
Fæ\ÌÏ™cp• Y.fjÊ2gDNydÄH&ßÑ!Ğ	Œle)ÃmÔäF(·5ÿyñ¹V©`§^QÒQÄ$¡€GÊÓ,Bl“pl¹ˆÌ)@Ë|ŸI9Î"XvpqĞn·Ö~=9¿8œéßï~>üëÉğı»}ønøáç“÷ìòŒ`æ˜BSåA”¹yH3úâıÅğä—£áÛÃÃóáÁ˜FÀM;/a,ÈZ ô†i@?Ó(l­Ïaéƒöú¿ô¾¬Šşh·Zk>Ê£½®_´«­µ5óv™%æÇ<Zûáø|®êŒ¹o³4åuS	Ğbaè!Â{ù<&©+¿ş›xãÊğõ¸ğ³ïrvóI’Å˜ €ìä”é‚é ú(:B©²¯áœ÷õĞ¡ŒÂY£ıÛdI‡´6
iÒŞ&í1H$ƒöV>İ
òC°a"ôI©U\ÍtTkM9ğŞ÷½› Ç'g‡¿œô_RÃÍ®P7‚°ÂD	ïòÍåÙğÒÃA
 
©ä6˜Ó6ÃÀu ìúê ¥Sç><³ÚqzlUc-e‰Ê– —eÂx²üÈE˜,UvÍ®µC+¾¥UÁˆT¯Ÿ÷G›<=  ÷¥¬­¸
›Y¯Í1 Y¤Q«­SdCıU1=0.óRGxè[dÆ 4%	öã£ı©`cLIƒÜÅğ±Yñ?àê/5Édw„ÜÉ	g×© %jÈÆ>iïv·Éİ€]u“,Šêk.ÁbT#»6(bê/*Ôjc]3Ê\
¥¨o>Å³¯Ï¬céõÈæà€d¶Õ)µÅûˆ
ãXêŠ«% R€£Ÿ¶ºÚ!§c²àÄ>ÖgÚ¶µƒ‡P«Ã˜ÎxmµÖ•œ0şÇjy¹¢X%®Ê:yéø‡‰ÚúL»©[Şl)_æøäÍéáÙ]—±²a™œ“½ÍÏ0ã²zùõD:ƒ^Q±höyŸàú½ÈxõõÈ S\-”€E%%®pÂñ‚6Tİ g¦ñíû6gf1—Íâi&ª\¼Tè›‡«±µ,Ìãr9£¡dÉ}X¸‚Ä[(4
*Ó?­_?·È­ôìßÖ£Î ù½LŞŸ÷6M†[Au	±6~ãñ‚ÎV)«zF‰÷7	—Û°
ı©Nğ‰œ‡ÊŸ²ÀÎ‡= Ì<›La_°»³Ûë\çRºÂ@‚pP=ÄjĞ%p£ÔF–z6ö¶sB½Å
<ÍB9…¯ÿkpÌX&[vGS¥RÙïv'¡šf£jÊùJ™1ÙİÿşÕîÃ]áîÎ]Õº™GwRöULª0Â‡@å:Â[ÜEş¦BiŒ›(mHökiYeâ"‹ĞáN á°oŒX›»šß×ÄRLİ€ØÀ²?’cØs	zš·á`	åşl±¤QLuú¹Løˆ
ºä)Kbš"¼¢KI“	éR„°Ã•K?âY`FÛIJ:çÀâğºDÊ¼»7^4şè„8Ó<ñôj÷RŞ‚qê5KÀ˜HV‚7&òED\[ù(aëíïM—2b!æïjëâÈîíT}\¤iî(jë¨,ElÎXğÉ…Ê¡wZ÷âĞÜ4`#îFIïegïNğ©ğ§Kü "^bFJ¯x&@ß É$€ï	Yà¨;­ë¹±1¼¹tJı8÷éfi¸ı_*øÒ~{€A¹Œ}øeV¢%öùÎ˜¦³JöÉ¥Š©˜±Š‡7‹<n^ç ¼3E.N½ÒØMr^.°L>'™0YK
æ«hÑoPp’‰«Ğg²Sv†X‚µ<ğ„˜Aı`geD‹×ƒ[ıİ]¤r=J¥Kì­Ÿ?,ìÅ„¹€mñËÇ‘tVÙpûßbë‘N¹âW6÷_„"åºÿ–IŸÇƒ>™Ëèµ{/	ødñšüĞ_éê2F,ÖŸ±	€]c,Kó¼Í!9¦Ø¶¬i1)«œÛ¨¹ØÀùYÑˆPbaòhÈÑ‰+ó~U–S¨\¸¡«EÊ,¤²ÊGvü®Wx[XİÔÃ¶òêêÚO 2o.·òÜŞÃ¶aÌ#½İÎnÑøÁJW>®V¹Õ-¤9vM²(ÈÇ’1Ï°õ¥òÅp§ û·Ü.ø¹DGüŠÙ2™â¶^Ë:×7í/¯~7	z…îZ¥Z@ğ(IÎÃIãj†§h\…zLÅ<L 1õóï‚”óˆ;ñ€ô óÕ¯uB¼İ•¤Ğ4•
ÄR]ù-&).5ØÀrS—ztF·uÖ—+8ÄÅ6u(\š(TQ¬ìû™ˆ¶ÉPÜQÛ‹'ŒÄy;DZæ¦:°¥Ô†šóç¦>J¯ÀrĞƒì.Ïß´
}ÆšŠÖzX[¿õÆòâ-à¯‹Šz®µz’~ëıN¼×Ö:F…#\³2NÛxÅ¡Ûğb!2ØàÇ…Y-?ï“bKUvÚ­Z(³`VMuğ¼™gÃÁğäbøA£Ÿo+A£İ@†ÛK˜u~t°cG.‡ë›š$ì´Y mí¶ÈrI`ìúkKıúùÖ]w>A»O“„+ˆFöß%Ì:•11"3ÁL‹S‡k°pg´A@È† ™êÖ¥Ã¦!“
®i¦úÅÓõœ:Wlcy·:†Ä8^ltëş.vfM»pË!êiŞãÒMVcvÒø{¨.Ï..ß½œOŠf%z\íÃl7Ê„¼e^[š|~i¶—KÜË-İÄ2ÏW—ND{F¦ÌŸ‘9èƒ)Ïè7 ¹
0|>eZQ(™„W,)ú}ØEÎ¡Úc~J7L›´DY~·«WÀÒ~ ×«.¤Œ&K2Àp°ÁÏ¨B5V½Ww“hN,¬.–Ú&	/èñ‘&Ñù=ƒ$Î¥AaÂmW³¡fhŸî|›I?„“?ßPJ}H8_“ßÀÖt¿V®Áëbù"ÿüLôTó3!¸9e½Š€íšŞ.xMòİwäZ¦µrsÄ/‹ZC“î˜Bƒ^Ò†c½äJ5ÓáÕöóÇ—BäƒùW
šúp$YiJtøÜFw0£ÈÌ†m!ä:q•R÷Õ3Y2Â	«·cöüÖ×&ÂZNVé²LÏBu÷s	ë;ò´½ ˆÑÙb€% Qİ|×)êÃS*mgò{AFŠ‡Xt
Š'0Î'x¸F„xBõİ	Ÿö5Ï7—o·ï‚pığ&U¼Äç.@àÉÕÎ–‡Ëã"£…=}cNm- q ÙœÇî8ÓÛİHÎğdê…gbšEoÄà¿MRıXŒÇGíÀÿªáÎaëdÏ“ Ø¹9ôÕDfŸ"‡ğ£,`µ“C°e ı5ºáÌ O0ÙÓL¶ı`!]Då*îóD±0à'e\wnÚwß@—Ø:(Rkªİ¼øìiÛ<4ÇøÓ§yÀ\TÃ‘’*ğ3^R.Ô`¼è—'ÁB½×ƒDå	[x™¸k<ˆ†µKiú!!ŞFS>Ç¼öğìÃù`0„tââòxpPXÿf/ÛB³w³¯b<ú=£]ÉqeğÆ÷æ<Z™p8w›‹Cİ,Rd;Èºõ¦lS­Zº–ƒìÊyD Á¹r2¿ßğøX|Œ8×1]ïânóm *f·áçóáê±èÄ¤Ö‚y¸¢kòvÑmÌ¸ñ@e–j6vò”»ş^Ÿ@¬Pôa»rK§èFÔ³Q±:0wP}YcÀ#ñe¹ÙPNÚ6óŞ]Ím¤pšASs¼ƒ]kçeOKüt>8œ$<Ñ)9õUhv÷VØnqF&ÛB2d=5ê4I'ÍçŠÖQ‡ô¡Â‰æv ¡¹áE¾'òd’déÄ&ºú‹[µëV1%¡€]3ñ¼˜ì O_}Î_N©`İ¼áéÔ:ª$Ø„!Ãn—mº{¿ä¹C¥¦’X[W*½‡@B©J°Š1ã§ ~W‚Çâ%éÎév|àDÄ5Ë„Q—p*b.: Û:7™í­Ç\4È³¯:UÕxBå9ì/À*ôW*êJ=-³õ•´×¬¨Ö±×Æ„[€jÿÍ,hµ¯"bËÓøG•y¹TĞ8û«Ú “O£ı­HS½ÈL›¡n[ğ¼ ~{™H@le„gêíxqØ£ä…çÖCMù}…ê§·›q)yíâr'U	’q#áğÜ•íÜ{6PmVÉİÚ¨Îª3ã+p¢†\1îAœP7YQ–ÒŠ;ùÑ"ÈP?Ä'%îê«gº|²i ÂX‡ÁûŠ¸kXÂ3KiœÏ‰¡„ÂÃ	ñÄ—Ó„•KyàäÑLqKº HuìÚåô nXÚçrß°ßôÙo^áŸñ«ˆÚDüÀug“æEg“[I4]A¶]óÖ!ÚÛ6 AÓY	OmÙìäw²ñOÔ‡Îó.z˜,	Õb}#\3­a2T7ÜNX(’~¦²ÔƒzÜŠÃÜ9Ê•¡O¼^íˆI:Ã2é,eb«pö?M9¦D»6óWÃ"ı¯£FìmCÁé¥šXd>óÀ:ÓSƒP„ï™0|Ë€RY)ì½6ª¾ğVšÓimc^¡ÿ—³ƒ¶<Ê»J“nízbº85xXõ*]êÀ‡u™Ä'îÙ± ··ÿòÅ÷û½½İvÃ"ÕÎ@ò¯‹ã}Ø£ÏÀš’¢Ø¬•«¾¡oş;Me§bª€`¨ØSò–£¥é2‰NFÌ^¥ÜËŒyq£o7=nóYys;YJ%Kõ.ÖlçM½Ç‘êĞ°?ZúßgÿÇ}¼¯Çëñz¼¯Çëñz¼¯Çëñúpı*xw
 P  