#!/bin/bash

# 此脚本作用：
#    1. 将 PDF 文档分割为五部分
#         A 封面到扉页
#         B 原创声明到授权声明
#         C 摘要到参考文献
#         D 作者简介到致谢
#         E 附录
#    2. B 和 D 都通过处理使文字无法复制，得到B-rst，D-rst
#    3. 将 A，B-rst，C，D-rst，E 组合为新的 PDF 文档


# ！！！注意
# 执行此脚本需
#     1. 安装pdftk、Ghostscript并将其路径加入PATH环境变量
#           pdftk: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/
#           Ghostscript: https://www.ghostscript.com/download/gsdnld.html
#     2. 将TeX Live可执行文件路径加入PATH环境变量
#     3. 有类Linux环境，可执行cat、grep、awk、head等命令
#           Windows下安装Git并使用Git Bash可得到，Git: https://git-scm.com/downloads

# 检查是否提供了输入参数
if [ $# -eq 0 ]; then
    echo "错误：未提供输入文件名。"
    echo "用法：$0 <pdf文件名（不含扩展名）>"
    echo "示例：$0 main"
    exit 1
fi

pdfName=$1
makeUnselectableSh="./makeUnselectable.sh"

# 检查输入的PDF文件是否存在
if [ ! -f "$pdfName.pdf" ]; then
    echo "错误：PDF文件 '$pdfName.pdf' 不存在。"
    exit 1
fi

# 检查makeUnselectable.sh脚本是否存在
if [ ! -f "$makeUnselectableSh" ]; then
    echo "错误：makeUnselectable.sh 脚本不存在。"
    exit 1
fi

# 检查必要的工具是否安装
check_command() {
    if ! command -v "$1" > /dev/null 2>&1; then
        echo "错误：未找到命令 '$1'。请确保已安装并加入PATH环境变量。"
        exit 1
    fi
}

echo "检查必要工具..."
check_command pdftk
check_command gs
check_command grep
check_command awk
check_command head
echo "所有必要工具检查完毕。"

# 清理之前的临时文件
echo "清理之前的临时文件..."
rm -f $pdfName-crosscheck-*.pdf $pdfName-crosscheck-*.ps $pdfName-crosscheck-data.info

# 提取原文档的数据信息，如meta-data、bookmark等
echo "提取PDF文档的元数据和书签信息..."
pdftk $pdfName.pdf dump_data_utf8 output $pdfName-crosscheck-data.info

# 检查数据提取是否成功
if [ $? -ne 0 ] || [ ! -f "$pdfName-crosscheck-data.info" ]; then
    echo "错误：无法提取PDF文档的数据信息。"
    exit 1
fi

info_file=$pdfName-crosscheck-data.info

# 通过章节题目从书签信息中提取页码
get_page_num(){ 
    mark=$1
    echo "正在查找书签：$mark"
    line_num=$(grep "$mark" -n $info_file | grep "BookmarkTitle:" | awk -F ':' '{print $1}' | head -n 1)
    # echo $line_num
    if [ -z $line_num ]
    then 
        echo "  未找到书签：$mark"
        return 0
    else
        line_num=`expr $line_num + 2`
        # echo $line_num
        r=`head -$line_num $info_file|tail -1|awk '{print $2}'`
        echo "  找到书签：$mark，页码：$r"
        # echo $r
        return $r 
    fi
}

echo "开始提取各章节页码..."

# 提取各章节的页码
get_page_num 封面
coverPageNum=$?
echo "封面页码：$coverPageNum"

get_page_num 扉页
titlePageNum=$?
echo "扉页页码：$titlePageNum"

get_page_num 学位论文原创性声明
originalStatementPageNum=$?
echo "原创性声明页码：$originalStatementPageNum"

get_page_num 关于学位论文使用授权的声明
contributionStatementPageNum=$?
echo "使用授权声明页码：$contributionStatementPageNum"

get_page_num "摘 要"
cAbstractPageNum=$?
echo "摘要页码：$cAbstractPageNum"

get_page_num 参考文献
referencePageNum=$?
echo "参考文献页码：$referencePageNum"

get_page_num 作者简介
selfIntroPageNum=$?
echo "作者简介页码：$selfIntroPageNum"

get_page_num "致 谢"
acknowledgmentPageNum=$?
echo "致谢页码：$acknowledgmentPageNum"

get_page_num 附录
appendixPageNum=$?
echo "附录页码：$appendixPageNum"

# 获取文档总页数
lastPageNum=$(grep "NumberOfPages:" $info_file | awk -F ' ' '{print $2}')
echo "文档总页数：$lastPageNum"

# 检查必要的页码是否找到
if [ $coverPageNum -eq 0 ] || [ $titlePageNum -eq 0 ] || [ $originalStatementPageNum -eq 0 ] || 
   [ $contributionStatementPageNum -eq 0 ] || [ $cAbstractPageNum -eq 0 ] || [ $selfIntroPageNum -eq 0 ]; then
    echo "警告：某些必要的书签未找到，可能会影响PDF分割结果。"
    echo "请检查PDF文档是否包含正确的书签信息。"
fi

echo "开始分割PDF文档..."

# A部分：封面到扉页
echo "正在生成A部分：封面到扉页..."
pageRange=$coverPageNum-$titlePageNum
pdftk $pdfName.pdf cat $pageRange output $pdfName-crosscheck-A.pdf
if [ $? -ne 0 ]; then
    echo "错误：生成A部分失败。"
    exit 1
fi
echo "A部分生成完成：$pageRange"

# B部分：原创声明到授权声明
echo "正在生成B部分：原创声明到授权声明..."
pageRange=$originalStatementPageNum-$contributionStatementPageNum
pdftk $pdfName.pdf cat $pageRange output $pdfName-crosscheck-B.pdf
if [ $? -ne 0 ]; then
    echo "错误：生成B部分失败。"
    exit 1
fi
echo "B部分生成完成：$pageRange"

# C部分：摘要到参考文献前
echo "正在生成C部分：摘要到作者简介前..."
pageRange=$cAbstractPageNum-`expr $selfIntroPageNum - 1`
pdftk $pdfName.pdf cat $pageRange output $pdfName-crosscheck-C.pdf
if [ $? -ne 0 ]; then
    echo "错误：生成C部分失败。"
    exit 1
fi
echo "C部分生成完成：$pageRange"

# D部分和E部分：根据是否有附录决定分割方式
if [ $appendixPageNum -eq 0 ]
then
    # 没有附录：D部分包含作者简介到文档末尾
    echo "未发现附录，D部分：作者简介到文档末尾..."
    pageRange=$selfIntroPageNum-$lastPageNum
    pdftk $pdfName.pdf cat $pageRange output $pdfName-crosscheck-D.pdf
    if [ $? -ne 0 ]; then
        echo "错误：生成D部分失败。"
        exit 1
    fi
    echo "D部分生成完成：$pageRange"
else
    # 有附录：D部分为作者简介到附录前，E部分为附录到文档末尾
    echo "发现附录，D部分：作者简介到附录前..."
    pageRange=$selfIntroPageNum-`expr $appendixPageNum - 1`
    pdftk $pdfName.pdf cat $pageRange output $pdfName-crosscheck-D.pdf
    if [ $? -ne 0 ]; then
        echo "错误：生成D部分失败。"
        exit 1
    fi
    echo "D部分生成完成：$pageRange"

    echo "正在生成E部分：附录到文档末尾..."
    pageRange=$appendixPageNum-$lastPageNum
    pdftk $pdfName.pdf cat $pageRange output $pdfName-crosscheck-E.pdf
    if [ $? -ne 0 ]; then
        echo "错误：生成E部分失败。"
        exit 1
    fi
    echo "E部分生成完成：$pageRange"
fi

# 对B和D部分进行文字不可复制处理
echo "正在对B部分进行文字不可复制处理..."
$makeUnselectableSh $pdfName-crosscheck-B.pdf
if [ $? -ne 0 ]; then
    echo "错误：B部分文字不可复制处理失败。"
    exit 1
fi

echo "正在对D部分进行文字不可复制处理..."
$makeUnselectableSh $pdfName-crosscheck-D.pdf
if [ $? -ne 0 ]; then
    echo "错误：D部分文字不可复制处理失败。"
    exit 1
fi

# 删除原始的B和D部分，保留处理后的版本
echo "删除原始B和D部分文件..."
rm -f $pdfName-crosscheck-B.pdf
rm -f $pdfName-crosscheck-D.pdf

# 合并所有部分为最终文档
echo "正在合并所有部分为最终文档..."
# 见 https://blog.dbrgn.ch/2013/8/14/merge-multiple-pdfs/
#pdfunite `ls $pdfName-crosscheck-*.pdf -v` $pdfName-CrosscheckVersion-tmp.pdf #会使超链接失效
#pdfjoin `ls $pdfName-crosscheck-*.pdf -v` -o $pdfName-CrosscheckVersion-tmp.pdf #会使超链接失效
pdftk `ls $pdfName-crosscheck-*.pdf -v` cat output $pdfName-CrosscheckVersion-tmp.pdf
if [ $? -ne 0 ]; then
    echo "错误：合并PDF文件失败。"
    exit 1
fi

# 清理临时分割文件
echo "清理临时分割文件..."
rm -f $pdfName-crosscheck-*.pdf
rm -f $pdfName-crosscheck-*.ps

# 将原文档的数据信息，如meta-data、bookmark等，加到新拼成的pdf中
echo "正在添加原文档的元数据和书签信息..."
pdftk $pdfName-CrosscheckVersion-tmp.pdf update_info_utf8 $pdfName-crosscheck-data.info output $pdfName-CrosscheckVersion.pdf
if [ $? -ne 0 ]; then
    echo "错误：添加元数据信息失败。"
    exit 1
fi

# 清理最后的临时文件
echo "清理临时文件..."
rm -f $pdfName-CrosscheckVersion-tmp.pdf
rm -f $pdfName-crosscheck-data.info

echo "处理完成！查重版PDF文件已生成：$pdfName-CrosscheckVersion.pdf"

