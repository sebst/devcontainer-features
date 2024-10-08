#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3167377043"
MD5="f00dd9c0fe9112c81cd0d494fef189e8"
SHA="a8145aa22fd9a68a7c46db031671666675c6b345c4c8f4b20c860696df75517c"
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
filesizes="4405"
totalsize="4405"
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
	echo Date of packaging: Tue Oct  8 15:09:18 UTC 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself-2.5.0/makeself.sh \\
    \"--gzip\" \\
    \"--current\" \\
    \"--nox11\" \\
    \"--sha256\" \\
    \"/tmp/tailscale.com.njC2JcKn2s/\" \\
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
‹ Kgí;ïsÛ6²ùjıˆâ©íœ)YwÔqóÛ½ó4µ2¶Ü^æ½»DBŸH‚@ËÊ©ÿûí 	Ò”cÇI^oùAI`±¿w±uº,Qb‘ò0Q9}ò5®¸ö_¾ÄïŞşË¾ïíïëo¼^ìí<éííïôv÷^î½xõd§·÷êÅË'dçÉ7¸2©¨ TD–$L¬pvÛ{KKñır={ÚÍ¤èÂáŠxdDå”x^ÂSÁÇaÄôoá&»şLÃ”iáï„û˜07Y"™jµ˜?ådã .r|òëÑàlxxzvrŞ9üBğéF9‚üÄ¨Êë ¥O#ÖñyìŒXqm´ü€´+“Ú­N7L@¨QúÜzòxİzuºî9¬ûvöß{µW³ÿW¯z»öÿŸmÿ-Gµ<«VL<ÚäŸÛş›Eö5í¢ÿNÍşw{=° Gûÿ6ö¶VùŒñt!ÂÉT‘M‹sM §‰O¾#‡—Ã¿Î/`ÜÅ»ã¿{oCŸ¡{§$á8d¢OŞ\{/¼£ˆf’µÁÈá4”Dú"L	˜b¾’DMñ3ğ$‰"<e‚ª0™¹ŠÅÛ„&±š'@õ}.ª8À Š.6$ñyr…ğDvZ-p<ÄcYfF‘YŠŒ sAÓ”!pBILákœ%>N4Ğ&póQá·0€Œ¸R<&|¬A¡7Ü&Ò.O‰ñ©‚	)*¤	ø<‰8à“É†",	 L–vÍüLS:¥Ñ&®tZˆÊæùWk«XJz}Ëª
§¢0É®IJ%ø6¹bBæ†])õgtR2± ÚoŒ-GŠÁ¶AÎTÓäld	Ù†ßeÊïréÁ`F%CşCÀ@Ğ¸Lp¨YYv,€3€¢`dÎÅŒğL‘90çY	šåb¦¦< sFä”gQ@FŒdğÍÀ(ÀVf‘2ÜF½An„Òp[óŸGŸk˜
Æpê!EL
x¤<Í"È6	Ç–‹ˆÁœ´Ì÷™”ã,‚eívkí×“ó‹ÓÁ™şıîğèçÃ¿ß¿;Ñ÷‡ï†~>yÿÁ> ÏÈ f¹ 4UDI»‘‡4£/Ş_O~9¾ıp1<<ŒiÜ´óÆ‰¬âAo˜ô3ÂÖÚğ–>h¯ÿKÿè{À: èv«µæ£<ÚëúE¸ÚZ[3o—Yb~lÁ£µ~€Ïçú§Î˜Ûğ6KS.P7• ı †‚!¼—Ïc’ú°ğë¿‰7¾¡ÿøY?»ñ.g70Ÿ$YŒ	 ÈNN˜^!˜ê¡Ò¡#T‘Š û.ñÈéq_¿Ê(œ5:Ğ¿MÖ™tH;`£&ímÒƒôG2hoåÓ­ ?ä` &BŸä˜ZÅÕL7@µ†Ğd‘ï}ßÙÙ»	ğhp|rvøËI¿ğ%5Üì
up#+L”ğ.ß\/p0¤ ¢Jnƒ90m3\À®¯P:uîÃ3«§ÇV5Ö²Q–¨l	rY&Œ'Ë\„ÉRe×,àZ;´â›QZŒØAõêøy´ÉÓz_*ÀÚ«°™õÚEµúØ:Efğ8Ô_Óã2/uô‡¾uAfBS2‘`?>J ÙŸ
6Æ”4È]Û™ÿ®şR“Lvw@Èœpv
R¢†lì“önçy›üØØU7É¢È¡¾æ,F5²kƒ"6¡ş¢B­6Ö5£Ì¥PPŠúæS<ûúÌ:Ö¨‘^l¾H¶`[R[¼¨0Å¡®¸Z 8úi««r:&Aìƒ`aqÆ !°¡m[;xå°:ŒéÜ×Vk]Éy8 ã¬–—+ŠUâª¬S‘—¿q˜¨­Ï´›ºåİÉ–òeOŞœİuë(–©Ái0ÙÛÑü3^!«—_OT s1è‹fŸ÷	®ß‹ŒW_0eÁÕH	XTRâ
÷!/¸`CÕİ	pfïĞ¾ap6asÙ,f¢ÊEÁK…¾y¸[ËÂL0.—3J–Ü‡…+H¼…B³  2ıÓúõs‹ÜJÏşm=ê’ßûÈäıÉá9poÓd¸T—K`ã7î/èl•²ªgä˜x“p¹;¡ĞŸêŸÈy¨ü)ì|ØÀ,Á³Éö»;»½Îu(¥+$ØˆÕC¬]27Jmd©gco;Ç!ÔQÜ©ÀÓ,”Søú¿vÇŒ¥a²E`w4U*•ınwªi6ªÖ œ_¡”“İıï_í>ÜîîÜU­›yt'e_Å¤
#|T®#¼Å]äo*”É¸‰Ò6ä`¿––U&.²¸îûÆˆÕ±¹«ù}M,ÅÔˆ,û3 9†=— ·¡y–PîÏKÅT§ŸË„¨ K²$¦I Â+º”4™ğ˜.E;\¹ô#f´dñ¨¤Sp,¯K¤Ì»{ãEãNˆ£1ıÈO¯v/å-g ^³¬‰Ha%xc"_DÄµ‘¶ŞøŞt)#æbş®¶.ìŞNÕÇEšæ¢¶ÊâQÄæŒŸ\¨z§% y/}Á=A6ân”ô^vöîŸ
ºÄ*â%f¤ôŠgôLøP‘ºãØº^‘Ã›K§ÔsŸn–†Ûÿ¥‚/í·”ËØ‡_f%APbŸïŒi:«dŸ\ª˜Š«xx³ÈCà&áuĞÁ;Sä¢AàÔË!Í€İ´ gáõàËäãp’	“µ¡`¾ŠıvÅ'™¸
}&;egˆ%XËOˆÔvVQF´x]ñ0¸ÕßİE*×£TºÄNĞúùƒÁÂPL˜ØÖ¿|Ig•-—±ÿ-¶é”+îxesÿE(R®ûo™ôyp<è“¹Œ^»÷r‘ğˆO¯Éï	Mñ•®.c`Äbıé› Ø5Æ²4ÏÛ’cŠmËú˜“²Ê¹š‹]œŸ%&†è¹2ïGPÕi9…ªÁ…ºá¹Z¤ÌB*«|d÷Çïze€·…ÕM=l+¯®®ı*óæâx+OÁí=lÆ\0ÒÛíì¬tåãj•[İBšc×$‹‚|,ó[_*_w
°qËí‚KtÄ¯˜-“é n«áµ¬s}Ó¾ğòêw“ Wè®Uªµ’ä<œ4®fxê‰FÀU¨ÇTÌÃÄS?ñ.H9ÿ€¸H2_ıZ'ÄÛ]I
MS©@,Õ•ßb’âRƒ,7u©§A·at[g}¹‚C\Œ`S‡Â¥‰BÅÊ¾Ÿ‰h›Œ eÀµ½èpÂHœÇ±C¤µ`>aª[Jm¨é8nê£ô
,ı0ÈşèòüíA«Ğg\¡©h­‡µõ[o,/Şşº¨¨'áZ«'é·ŞïÄxmM cT8Â5+ãT°W°/"ƒ~\˜%Ñòó>)¶Te§İª…2fÕtPÀ›y6iO.†4úù¶4Úd¸½„YçG;vôàrx°¾©IÂN›ĞÖa‹,—Æ®¿¶Ô¯Ÿaİuç´û4I¸‚hDaÿ]Â¬SÓ#2Ì´8u¸K wÆ@$ „l8’©n]:l2©°ášfª_<]Ïé©sÅ6–wû¨cèAŒãÅF·îïbgÖ´·±Œ¢æ=.İd5f'¯±‡úáòìâòİ»Áùğäø hV¢ÇÕ>Ìv£LÈ[æ¥±¥Éç—f{¹Ä½ÜÒİA,ó|uéD´gähÊü™ƒ>˜òŒîy:« ÃçS¦…’IxÅ’¢ß‡]ä¼ª=æ§tÃ´I»@D‘åw¹z,ír±êBÊh²$ëüŒ*TcUÑ{u7‰æÄBÁêb©m’ğ‚¹`ß3HâQ&ÜĞy5j†€öéÎ·™ôC@8ùóı¨q å©DÑ÷‡„ó5ùlMwñiå¼.–/òÏÏDßI5?‚›SÖ«Ø®éí‚×$ß}Gş§eZ+7G¼€ø²¨54é)4è%m8ÖK®T3^-a¿10,q)t@>˜¥ ©×@’•¦D‡Ïmtó0ŠÌlØB®WY!u_=“%#œ°z;fÏo}m"¬ådu.ËôÜ Tw?7°¾ó(O»ĞŠ-XÕÍw" şá‰0<¥Òv&¿çd¤xˆE§ xbAã|‚‡kDˆG!Tßği_óÌ@psùvû.×Oa Ù€`RÅÛ@|î‘\íly¸<.2ZØÓ7æÔÖòÍyìÑ€3½İ€DáOö Yx&¦YôFLşÛ$5ÑÅx|Ôü¯Úî¶Nöñ<	€›C_MdVğ)r?ÊV;9[Ğ_£ëÎÀğ“=Íä`Û¿ÒET®â>O.pRÆuç¦}÷ˆt‰í¡ƒ"µ¦:ÑÍ‹Ïî¶ÍCsŒ?}šÌE5)©?ãõ!åB	Æ‹~y,Ô{=H„PN°…Wé»ÆƒhX»”ö¨ßâm„0åsÌkÏ>œCH'..…õo†ñ²-4{7û*Æ£ÏĞ3Ú•WfoÌqoÎÃ¡•¹‡€s·¹8ÔÍ’!E¶ƒ¬[oÊ–1Õª¥Ë`9È®œGœ+'óû…ÀÇˆsƒĞõn îæ0ß¢²av~î8ğ8®;€NLj-˜‡+º&oİÆŒTf©fc!ßH¹áïõ‰Ä*E¶+·tÚ€nD=«såØ—õ7<_–»å¤msÀ0ïİÕŒĞF
÷¡	45Ç;Øµv^ö´ÄOçƒ³áÉÙñAÂ’S_…fwo…ígt`²-$CÖS£N“tÒ|®huH*œhnš^ä{"oA&I–Nl" «¿¸U»nSâY
Ø5Ï‹yÀğô5Ñçüå”
ÖÍN­£J‚­A2ìvÙ¦»÷K;TúXa*Iµu¥Ò{Ô(”ª«3~
àw%øp,^âNàœnÇND\³Lxu	§"æ¢²­¡s“ÙÎÑzÌÕAƒ<ûªSU‡ T®‘Ãş¬²A¥¢®ÔÓ2[_I{ÍŠj{mL¸¨ößÌ‚&Pû*"¶<T™—Kcñ¸¿ª2ù4ZÑ_ĞŠ4Õ‹Ì´ê¶Ïá·—)€ÄVFx¦Şî‡=Š@^xh=„Ñ”ßW¨`pz»—’×..wâQ•ğ 7Ï]ÙnÀ½gÕf•Ü­ê¬:3¾'jÈãÄ	u“e)í¡¸“!‚õY±@|Râ®¾
y¦Ë×(k‘Æ  Œu¼/¡ˆ»öˆ%<³”Æ)ñœJ(<œO|9MX¹”çNÍ·„¡‚T‡Á®]Nï à†¥}.÷ûMÿ±‘ıæşÏ±j€¨IÄ\w6i^t6¹•DÓt`Û5o¢½m4Õ€ ğÔ–ÍN~'ÿD}è<ï¢‡É’P-Ö7òÀ5Ó&CÅqÃí„…"ég*K=¨Ç­8Ì£\êùÄëÕø˜¤3,“ÎR&¶
gÿÓ”cJ´k3õ0,Òÿ:jÄŞ6œ^ª‰Eæ3¬315Eø	Ã·¸!••BÁŞk£jàoU ©1ÖF0æú9;H`Ë£¼«4éVĞ¾¡'¦‹Sƒ‡U¯Òeà |Xw‘I|âz{û/_|¿ßÛÛm7,Rıç$ÿº8Ş‡=ú¬))ŠÍZ¹êúæ¿ÓTv*¦Ú ¨†Š=%o9Zš.“èdÄìUÊ½Ìh‘7úvÓã6_•7·“¥T²TïbÍvŞÔ{L© û£¥ÿ}öøÜÇëñz¼¯Çëñz¼¯Çëñz¼¯ÿ×¿,Xù P  