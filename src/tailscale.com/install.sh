#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1617835051"
MD5="725949bb48e6fdb1a318ec4cc51271de"
SHA="6609aa8cd8fc0e510bec2765795c65e8bd4ef060275253d66e462abb09f4fa3b"
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
	echo Date of packaging: Tue Oct  8 15:10:29 UTC 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself-2.5.0/makeself.sh \\
    \"--gzip\" \\
    \"--current\" \\
    \"--nox11\" \\
    \"--sha256\" \\
    \"/tmp/tailscale.com.qCtjTYfkrD/\" \\
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
‹ eKgí;ïsÛ6²ùjıˆâ©íœ)YwÔqóÛ½ó4µ2¶Ü^æ½»DBŸH‚@ËÊ©ÿûí 	Ò”cÇI^oùAI`±¿w±uº,Qb‘ò0Q9}ò5®¸ö_¾ÄïŞşË¾ïíïëo¼^ìí<éííïôv÷^¾Üƒq½½W/^=!;O¾Á•IE "²$abõ¸€û³ÛŞ[ZŠïÿëÙÓn&Ew& WÄ» #*§Äó
>#¦Ÿxœ0!Øu¨ğg¦lLÃ'ÜøhÄ„¹ÉÉT«Åü)'p‘ã“_gÃÃÓ³“óÎÑà‚O7Êä'FU&XŸ( )}±ÏcgÄŠk£å¤]™ÔnuºaB"ĞçÖ“ÇëÖ«Ó­pÏaİ·³ÿŞ«½šı¿zÕ{ñhÿÿÙößrTË³jÅÄ£Mş¹í¿Yd_Óş!úïÔì·×Ûé=Úÿ7²´}°Êgäˆ§N¦Šlú[d˜k9M|ò9¼şmp~ã.Şÿİ{úİ; Ç!}òæâØ{áE4“¬õF§¡$ÒaªHÀó•$jÊˆŸ'Iá)T…É„È…T,Ş&4	ˆÕ<‰ 
$¨ïsàPÅUdp±!‰Ï“+D€'²Ójã!ËZ0ó0ŠÌR<`°˜š¦Jb
_ã,ñq¢6a€›
¸…© dÄ•â1ác
½á6‘vyJèŒOLH©P!HÀçIÄi ?˜L6aI `²”°kægšÒ)Æ0Ùp¥ÓBT6·È¿ZkÀXÅRÒë[VU8…IvM‚P*Á·É07ìJ©?£“’‰ …Ğ~cD°hA8R¶r¦š^ g#KhÌ6ôü.S~—K3*òwŞ ‚&Àe‚CõÈÊ²cœ#s.f„gŠÌ18ÏJĞ,35å™3"§<‹2b$“€oèèF¶2‹”á6êr#”†Ûšÿ<Šø\«ÀT0†S¯¨é(b’PÀ#åi¡@¶I8¶\Dæ e¾Ï¤g,;¸8h·[k¿œ_œÎôïw‡G?şõdøşİ‰¾?|7üğóÉûöyF	0sÌ¡©ò J‚Ü<¤}ñşbxòËÑğí‡‹ááùğ`L#à¦—0Hd-zÃ4 Ÿi¶Ö†ç°ôA{ı_úGßÖE´[­5åÑ^×/ÚÀÕÖÚšy»Ìóc­ığ|>×?uÆÜ†·Yšrº©è±0ôá½|“Ô‡•€_ÿM¼ñeøÇÈz\øÙw9»ù$ÉbL @vrÊÀô
ÁtP}”¡ŠTÙ×p‰GNûúhˆPFá¬Ñşm²Î¤CÚ…4io“ö¤?’A{+Ÿnù!Ø0ú$ÇÔ*®fºª5„&‹xïûÎÎŞM€Gƒã“³Ã_Nú…/©áfW¨ƒAXa¢„wùæòlxé€ƒá …TrÌi›aà: v}u€Ò©sYí8=¶ª±–²DeKË2a<Y~ä"L–*»f×Ú¡ßŒÒª`ÄªWÇÏû£MĞûRÖÖ\…Í¬×æ€,Ò¨ÕÇÖ)2ƒÇ¡şª˜—y©£‡<ô­2cš’‰ûñQÈşT°1¦¤AîbøØÎ¬øpõ—šd²»Bîä„³ëT5dcŸ´w;ÏÛäÇnÀ®ºIEõ5—`1ª‘]±	õjµ±®e.…‚RÔ7ŸâÙ×gÖ±Fôzdóp@²Ûê”Úâ}D…q,uÅÕ )ÀÀÑO[]íÓ1Yğbk‹3	mÛÚÁC(‡ÕaLç¼¶ZëJÎƒÀÿcµ¼\Q¬WeŠ¼tüÃDm}¦İÔ-ïN¶”/s|òæôğì®ËXGÙ°LNƒÉŞæg˜ñ
Y½üz¢‹A¯¨X4û¼Opı^d¼úzd€)®–@JÀ¢’W¸áxÁªîN€3Óx‡öı›€³	³˜Ëfñ4U.
^*ôÍÃÕØZf‚q¹œÑP²ä>,\Aâ-š•éŸÖ¯Ÿ[äVzöoëQgüŞG&ïOÏ{›&Ã­ º„X¿qxAg«”U=#ÇÄû›„ËmØ	…şT'øDÎCåOY`çÃ f	M¦°/ØİÙíu®ó@)]a ÁF8¨b5è’	¸Qj#K={Û9¡ŞˆâNf¡œÂ×ÿµ8f,“-»£©R©ìw»“PM³Qµåü
¥Ì˜ìîÿj÷á®pwç®jİÌ£;)û*&UáC rá-î"S¡4HÆM”¶	$ûµ´¬2q‘Åèp'ĞpØ7F¬Í]Íïkb)¦n@l`ÙŸÉ1ì¹½ÍÛp°„r¶XÒ(¦:ı\&|D]ò”%1M^Ñ¥¤É„Çt)BØáÊ¥ñ,0£í$ƒˆG%‚s`qx]"eŞİ/tBéGxzµ{)oÁ8õš%`L¤@
+Áù""®-ˆ|”°õöÀ÷¦K1Çówµuqd÷vª>.Ò4wµuT"6g,øäBåĞ;-È{qèî	š@°w£¤÷²³w'øTøÓ%~P/1#¥W< o€dÀ÷„Š,pÔÇÖõŠÜØŞ\:¥~œût³4Üş/|i¿=À \Æ>ü2+Ñ‚û|gLÓY%ûäRÅTÌXÅÃ›E7	¯s€ÆŞ™"§^iì¦9¯X&‡“L˜¬%óU´è·(8ÉÄUè3Ù);C,ÁZxBÌ ~°³Š2¢ÅëŠ‡Á­şî.R¹¥Ò%v‚ÖÏv„bÂ\À¶†øåãH:«l	¸Œıo±õH§\qÇ+›û/B‘rİË¤ÏƒãAŸÌeôÚ½—‹„G|²xM~OhŠ¯tu#ëOÇØÀ®1–¥yŞæSl[ÖÇ´˜”UÎmÔ\ì
àü¬hD(±0y4äèDÏ•y?‚ªNË)T.ÜĞÏÕ"eRYå#»?~×+¼-¬nêa[yuuí'P™7Ç[y
nïaÛ0æ‚‘Şng·hü`¥+W«ÜêÒ»&YäcÉ˜gØúRùb¸S€}ˆ[n|„\¢#~Ål™Lq[¯eë›ö…—W¿›½Bw­R­ x”$çá¤q5ÃSO4®B=¦b&Ğ˜úyˆwAÊùÄx@zùê×:!ŞîJRhšJb©®ü“—l`¹©K=º…£Û:ëËâb›:.Mª(VöıLDÛd(î¨íE‡Fâ<"­ó	SØRjÃ@MÇùsS¥W`9è‡AöG—çoZ…>ã
MEk=¬­ßzcyñğ×EE=	×Z=I¿õ~'ŞÀkk£Â®Y§‚m¼âĞ€mx±lğãÂ,‰–Ÿ÷I±¥*;íV-”Y0«¦ƒ:ø ŞÌ³aH‹`xr1ü ÑÏ·• Ñn Ãí%Ì:?:Ø±£—ÃƒõMMvÚ,€¶ö[d¹$0vıµ¥~ıüë®;Ÿ İ§IÂD#
ûïfÊ˜Î‘™`¦Å©Ã5X¸3Ú  dÃ	LuëÒaÓI…×4SıâézNO+¶±¼ÛGCb/6ºu;³¦]¸e„õ4ïqé&«1;é|=Ô—g—ïŞÎ‡'ÇE³=®öa¶eBŞ2/-M>¿4ÛË%îå–îb™ç«K'¢=#GSæÏÈôÁ”gtÏĞ\>Ÿ2­(”LÂ+–ı>ì"çPí1?¥¦MÚ"Š,¿[ÈÕ+`i?ëŒURF“%™`8XÏàgT¡«ŠŞ«»I4'
VKm“„ôøÈ“èüAgˆÒ 0á¶€Î«ÙP3´Ow¾Í¤ÂÉŸïG(O%Š¾?$œ¯Éo`kº‹_H+×€àu±|‘~&úNªù™Üœ²^EÀvMo¼&ùî;ò?-ÓZ¹9âŒÀ—E­¡IwL¡A/iÃ±^r¥šéğj	ûùc‰K¡òÁü+M}¸’¬4%:|n£;˜‡QdfÃ¶r¸Ê
©ûê™,á„ÕÛ1{~ëka-'«ƒtY¦ç¡ºû¹„õGyÚ…^PÄèl1À¨n¾ëõO„á)•¶3ù=Ï #ÅC,:Å
ç<\#B<
¡úî„Oûšg‚›Ë·ÛwA¸~x
È“*Şâs ğˆäjgËÃåq‘ÑÂ¾1§¶8€lÎcwŒœéín$
gx²uÈÂ31Í¢7b
ğß&©‰~,Æã£vàÕÎpç°u²çI ìÜúj"³‚O‘CøQ°ÚÉ!Ø2€ş]‡pf€'˜ìi&Ûş°.¢r÷y¢Xp‰€“2®;7í»ï@ Kl©5Õ‰n^|v‡´mšcüéÓ<`.ªáHIø¯)jH0^ôË“`¡ŞëA"„r‚„-¼‚LÜ5DÃÚ¥´GıÆo#„)Ÿc^{xöá|0B:qqy<8(¬3ˆ—m¡Ù»ÙW1}†Ñ®ä¸2xc{s­Ì8œ»ÍÅ¡n–)²dİzS¶Œ©V-]ËAvå<"€€à\9™ßox|,>Fœë„®wq7‡ù6•³ÛğsÇÇùpõØtbRkÁ<\Ñ5y»è6fÜx 2K5»ùFÊ]¯O V	(ú°]¹¥Ót#êÙ¨X˜;(Ç¾¬¿1à‘ø²Ü…l('m›†yï®f„6R¸MÈ ©9ŞÁ®µó²§%~:œOÎè”œú*4»{+l·8£“m!²uš¤“æsEë¨CúPáDs;€ĞÜğ"ßy2I²tb]ıÅ­Úu«˜Ï‚PÀ®™x^Ìv€§¯‰>ç/§T°nŞğtjUlÂa·Ë6İ½_òÜ¡ÒÇ
SI
¬­+•ŞC F¡T%XÅ˜ñS ¿+Á‡cñ‡tçt;>p"âšeÂƒ¨K81m›ÌvÖc®äÙWªj<¡rö`•ú+u¥–ÙúJÚkVTëØkcÂ-@µÿf4ÚW±åiü£Ê¼\*h‹ÇıUmÉ§ÑŠş‚V¤©^d¦ÍP·-x^¿½L$ ¶2Â3õv¼8ìQòÂó@ë!Œ¦ü¾BuƒÓÛÍ¸”¼vq¹ª„É¸‘pxîÊvî=¨6«änmTgÕ™ñ8QC®÷ N¨›¬(KiÅühd¨ÈŠâ“wõUÈ3]¾FY‹4 a¬Ãà}	EÜµG,á™¥4N‰çÄPBáá„xâËiÂÊ¥<pòh¦¸%]¤:vírz 7,ís¹oØoúì7¯ğÏxUDmH"~àº³Ió¢³É­$š® Û®yëím é¬†§¶lvò;Ùø'êCçy=L–„j±¾‘®™Ö0*n',I?SYêÁ@=nÅaîåÊPÏ'^¯vÄÇ$a™t–2±U8ûŸ¦S¢]›ù«‡a‘ş×Q#ö¶¡àôRM,2Ÿy`éŒ©A(Â÷L¾eÀ©¬
ö^U_x«Mˆé´6‚1¯ĞÿËÙA[å]¥I·‚ö=1]œ<¬z•.uàÃº‹Lâ÷ìXĞÛÛùâûıŞŞn»a‘ê?g ù×Åñ>ìÑg`MIQlÖÊUßĞ7ÿ¦²S1Õ@0Tì)yËÑÒt™D'#f¯RîeF‹¼¸Ñ·›·ù‚¬¼¹,¥’¥zk¶ó¦Şc‚HuhØ-ıï³Çÿã>^×ãõx=^×ãõx=^×ãõxı?¸şº«Ş P  