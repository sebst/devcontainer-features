#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2899864565"
MD5="f7cb51de8120c246e1039582d8e60b29"
SHA="aa4531962869390d652ca6ae9ec0fdd28e5da87b21fb0b6872b3d6a388c7688b"
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
filesizes="4404"
totalsize="4404"
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
	echo Date of packaging: Tue Oct  8 16:07:46 UTC 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself-2.5.0/makeself.sh \\
    \"--gzip\" \\
    \"--current\" \\
    \"--nox11\" \\
    \"--sha256\" \\
    \"/tmp/tailscale.com.MevWkkgNXK/\" \\
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
‹ ÒXgí;ïsÛ6²ùjıˆâ©íœ)YŠwÔqóÛ½ó4µ2¶Ü^æ½»DBŸ(‚@ËÊ©ÿûí 	Ò”cÇI^oøAI`±¿w±µÚ,Vb‘ğ0V-9yò5®=¸^¾ÄïÎÁË¾ïèo¼^ìï=éììuº/÷_t»Oö:û¯ºOÈŞ“op¥RQ¨ˆ4™X=.àşô®÷––üû?äzö´JÑ†1(Â5ñ.ÉÊ	ñ¼˜'‚ÂˆéßÂ''Lv*ü™„	Ñ0Âß1÷#>2anÒX2Õh0ÂÉÖ!\ääô×ãşùàèìüô¢uÜÿ…àÓ­bù‰Q•
Ö#
@JŸF¬åó™3bÅµÕğÒ,Mj6Zí0¡FèsãÉúºójµKÜsX÷íì¿ój¿bÿ¯^íí¯íÿ?ÛşjyV­˜XÛäŸÛşëEö5í¢ÿ^Åş»½ƒîÚş¿‘ı£íƒU>#Ç<Yˆp<QdÛß!ƒLÈYì“ïÈÑÕàoı‹KwùîäïŞÛĞg`èŞY 	d8
™è‘7—'Şï8¢©dg0r0	%‘¾E¦˜¯$QFü<I¬O˜ *ŒÇD.¤b³]Bã€XÍ“ G‚ú>U`PEú—[’ø<¾Fx,[8â±´3¢È,ÅF ‹¹ IÂ8¡dFák”Æ>N4ĞÆpóQá·0€¹R|FøHƒBo¸K¤]:ãS*TH#ğyqÀ&ã-EX ˜4!ì†ù©¦tB£L6\i5•íò¯Æ0V±„tz–U%NEaœŞ ”Jğ]rÍ„Ì»êOé¸`b@!´ß,Zƒmƒœ©¦ÈÙJc:c[z~›)¿Í¥ƒ•ù;
o Acà2Á¡zdiÙ‘ Î Š‚‘9SÂSEæÀœg%h–›15á™3"'<2d$•€o†è èF¶2”á6êr#”†Ûšÿ<Šø\«ÀD0†S¯©é0b’PÀ#áI¡@vI8²\Dæ ¥¾Ï¤¥,Û¿<l6¿^\õÏõïwGÇ?ıõtğşİ©¾?z7øğóéûöyFú10sÄ¡‰ò J‚Ü<¤}ùşrpúËñàí‡ËÁÑÅàpD#à¦3Hd-zÃ4 Ÿi66°ôasó_úGÏÖE4åÑÜÔ/šÀÕÆÆ†y»Lcócmüğ|>×?uÆÜ„·i’pº©è±0ôál“Ô‡•€_ÿM¼Ñ-eøÇÈz\øÙ­w»ù$Ng˜ €ìä„éå‚i¡ú(:D)	²§áœôôĞ¡ŒÂY£ıÛf­q‹46iÜÜ%ÍH(ƒæN6İ
òC°a"ôI†©U\ÍtTkğÎ÷­½ıÛ û'§çG¿œör_RÁÍ®P7„°ÂDïêÍÕùàÊÃA
 
©ä.˜Ó6ÃÀu ìêê ¥Uå><³ÚqvbUc#¦±J— —eÌx¼üÈE/UzÃ®µC+¾¥UÁˆT¯ŠŸ÷G“<=$ ÷…ll¸r›Ù¬Ì1 Y¤Q«­RdBıU2=0.óRGxè[dÊ 4Åc	öã£ı‰`#LIƒÌÅğ‘Yò?àê¯4É¤»Bne„³›D5dc4»­çMòc;`×í8"‡úŠK°UÈ®ŠØ˜ú‹µÚX7Œ2BA)ê›Oñìë3ëD£F:²ı8 Ù‚í´
mñ>¢Â8‡ºâj	€`àè§­®¶ÈÙˆ,x
±‚5„Å)ƒ„À†¶]íà!”Ãê0¦u^[­u%çAà Œÿ±Z^®(V‰«´NI^:şÎÂXí|¦İT-ï^¶”-srúæìèü¾ËXGY³LNÉŞæg˜ñ
Y½üz¢›^Q±¨÷yŸàúƒÈxõõÈ S\-”€E%®pÃñœ6TİŸ g¦ñÍ‡6g¦3.ëÅSOT±(x©Ğ7WckY˜
ÆårJCÉâ‡°p‰wPhT&Z¿~a‘[éÙ¿­GBòû™¼?=º îm›·„êb	lüFâ­BVÕŒïo.wa'úà9•?a{ ˜%x:À¾ »×í´n²@)]a ÁF8¨b5è‚	¸Qj"K={›¡ŞˆâN¦¡œÀ×ÿµ8a,	ã»£‰R‰ìµÛãPMÒa¹åü
¥L™l|ÿªûxWØİ»¯Z×óè^Ê¾ŠI%Fø¨\Gx‡»ÈŞ”(âQ¥MÉÁA%-+M\¤³t¸h8ì#VÅæ¾æ÷5±7 Ö°ìÏ€äö\‚Ş…æ]8XB¹?],i4£:ı\Æ|H]ò„Å3"¼¦KIã1ŸÑ¥a‡+—~ÄÓÀŒ¶“"•tÎÍÂ›)óîÁxÑÙG'ÄÑıÈcO¯ö åÍg Ş°¬‰Haxc"_DÄ•‘¶ŞøŞd)#æbö®².lßMÕÇE’d¢²JgÃˆÍ>¹P1ô^K òŞ,ô÷!ØˆûQÒyÙÚ¿|*üÉ?¨˜-1#¥×< o€dÀ÷˜Š4pÔÇVõŠÜÚŞ^:¡ş,óéfi¸ı_*øÒ~{€A±Œ}øeV¢%öùÎ˜&ÓRöÉ¥šQ1e%oyÜ8¼É #xgŠ\4œz9¤°›ä<¼é_b™|Sa²– ÌWÑ¢×Ì¡8à$×¡Ïd«è±kyà	1ƒúÁÎÊËˆ¯kwú»ûHåf˜H—Ø1Z?4XØŠ1sÛâ—#É´´%àræ‹­G2áŠ;^ÙÜŠ”ëş&}îŸô{d.£×î½\Ä<âãÅkò{L|¥«Ë±X6Â& v±,Í³6‡ä˜bÛ²>¦Å¤¨rî¢æbW ç§y#B‰…É£!G'z®ÌúTµN¡ªé†nx®	³Š*éşø]§ğ¶°º­‡ídÕÕŸ@eŞ\ìd)¸½‡mÃˆF:İV7oü`¥+W©ÜêÒ»&idcÉˆ§ØúRÙb¸S€}ˆ[n|ˆ\¢C~Íl™Lq[¯d›Ûö…—U¿ë½Bw­Rmô!x$gá¤v5ÃSOÔ.C=¡bÆĞõ³ï‚”óˆ;ñ€ô õÕ¯UB¼îJRh’Hb)¯ü“—l`¹©K5ºƒ£Û:ëËâb›:.ª(VöıTD»d(î¨íy‡Fâ<"­ó1S-ØRjÃ@MÇùsS¥×`9è‡AöÇWo¹>ã
uEk=¬©ßz#yùğ×EE=	×Z=I¿õ~'^ßkj£Â®Y§‚m¼üĞ€mx±lğãÂ,‰–ŸõI±¥*[ÍF%”Y0«¦ƒ:ø ŞÌ³aH‹`pz9ø ÑÏ¶• Ñn Ãí%Ìº8>Ü³£ûWƒÃÍmMvÚ,€¦ö;d¹$0vóµ¥~óâë®{Ÿ İ§qÌD#
ûïf•Ê2"SÁL‹S‡k°pg´A@È†c ™êÖ¥Ã¦“
®IªzùÓÍŒ*Wlc¹ÛCCb/6ºu;³¦]¸‹e„õ4ëqé&«1;é|=ÔWç—WïŞõ/§'‡y³=®öa¶eBŞ2+-M>¿4ÛË%îå–îb™å«K'¢=#ÇæOÉôÁ”gtÏĞ\>Ÿ0­(”ŒÃkçı>ì"gPí1?¥¦MÚ"ò,¿ËÕËai?éŒURD“%`8XOÿgT¡
«òŞ«»I4'rVçKí’˜çôøÈ“èüBgˆÒ 0á¶€.ÊÙP=´Ow¾Í¤ÂÉŸF(K%ò¾?$œ¯Éo`kº‹ŸK+Ó€àu¾|~&úNªù™Üœ²ZEÀvM§^“|÷ùŸ†i­ÜñFàË¼ÖP§;¦Ğ —´áX/¹RÍtxµ„ıÆÀü±Ä¥Ğù`ş¥‚¦>\IV’>wÑÌÃ(2³a[¹Î¬Ì
©ûê©,á„Õ»1{~çka-'ËƒtY¦ã¡ªû¹…„õÇYÚ…^PÌĞÙb€% Qİ|×)êÃS*Mgò{BFŠ‡Xt
Š'0Î'x¸F„xBõÜ	Ÿö5Ï7—o6ïƒpõğ-&e¼Äç.@àÉÔÎ–‡‹ã"Ã…=}cNm- q ÙœÇî8ÓÛİ
HNñdê…gbšEoÈà¿KıØÚÿU9ÃÁÖÉ>'°ssè«Ì>yáGiÀ*'‡`Ë úktÂ˜`²§™l{·ÀBºˆÊ•ßg‰bnÀNÊ¸éÜ4ï¿1€®°=t˜§ÖT'ºYñÙÒ´yh†ñ§Oó€¹¨š#%eàç¼:¤X¨&ÁxÑ+N‚…z¯‰Ê	¶ğ2=p×xk—ÒõAB¼‹&|yíÑù‡‹~ éÄåÕIÿ0·şí0 ^ºƒfïf_ùxôzF³”ãÊ4àµ9îíy8´47àpî7‡ºY2¤ÈvuëuÙ2¦Z•t,Ù•ñˆ ‚såd~¿áñ±øq®cºŞ-ÄİæÛBT¶ÌnÃÏçÃÕg S“ZæáŠ®ÉÛEw1ãÆ•i¢ÙØFÈ·Rî\øû=b ±R@Ñ‡íŠ-6 [QÏFÅòÀÌA9öeıÄå.dC1i×0Ìzw#´‘Â}hBMÌñv£—=-ñÓEÿ|pz~róX§äÔW¡Ùİ[a»Å˜lÉõÔ¨Ó8×Ÿ+ÚDÒ‡
ÇšÛ„æšÙÈ[qœ&c›èê/nÕnù”Ù4ìš‰çÍxÀñô5Ñçüå„
ÖÎN­£L‚­A2ìvÙ¦»K[TúXa*Hµu¥Ò{Ô(”ª «3~
à·%øp,^âVàœnÇNDÜ°Lxu1§bÆEd[Aç6³£õ˜«ƒyöU«¬A¨X#ƒıXeƒşJE]©§E¶¾’öŠU:öÚ˜pPî¿™M öUDlyÿ¨2/–
jÇâqUdòi´¢¿ iª©i3Tmç$Âo/U 	ˆ-ğL½İ/{¼ğ<Ğz£	¨PÁàôf=.¯]\îÅ£2áA<ª%»²İ‚{Ïªí2¹;[åYUf|NTËÇ=Šê6+ŠRÚcq'?Cê²dø¤À]}òL—¯VÖ"™€p¦ÃàC	EÜµG,à™¥4N±çÄPBáá˜xâËiÂÊ¥<pòhª¸%]¤:vírr ·,ís¹oØoúµì7¯ğÏxUDmHböÈu§ãúE§ã;I4]A¶]óÎ!ÚÛÖ A“i	OmÙìôw²õOÔ‡Öó6z˜4Õbs+\S­a2T7ÜNXÈ“~¦ÒÄƒzÜŠÃÜÊ¥¡O¼NåˆI:Ã"é,db«pö?M¦D»6óWÃ"ı¯£ZìmCÁé¥šXd>³À:ÕSP„ï™0|Ç€[RY)ì½Öª¾ğVš
Ói­c^¡ÿ—ÓÃ¶<Ê»Nâv	í[zbº8xXõ*\jÁ‡u©Ä'îÙ± ³ğòÅ÷ın³f‘ò?g ù×ÅñìÑ§`Mq^lÖÊUİĞ×ÿ¦´S1Õ@0Tì)yËÑÒt™D'#f¯Rìe†‹¬¸Ñ³›·ù‚¬¼½,¤’&zk¶ó¦Şc‚HyhØıï³õÿq××úZ_ëk}­¯õµ¾Ö×úZ_ëëÿÁõoË¤¾° P  