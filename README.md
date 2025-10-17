# 吉林大学硕博论文 TeX 模板
[![GitHub stars](https://img.shields.io/github/stars/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT/network/members)
[![GitHub issues](https://img.shields.io/github/issues/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT/issues)
[![GitHub watchers](https://img.shields.io/github/watchers/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT/watchers)
[![GitHub license](https://img.shields.io/github/license/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT/blob/master/LICENSE)
[![Repo Size](https://img.shields.io/github/repo-size/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT)
[![Contributors](https://img.shields.io/github/contributors/IammyselfYBX/JLU_TLT)](https://github.com/IammyselfYBX/JLU_TLT/graphs/contributors)

# 使用方法
默认的配置就是 **学术学位硕士印刷版**，,详细方法可见[Wiki](https://github.com/IammyselfYBX/JLU_TLT/wiki)
## 1.下载
```bash
$> git clone git@github.com:IammyselfYBX/JLU_TLT.git
```
或
```bash
$> git clone https://github.com/IammyselfYBX/JLU_TLT.git
```

> 如果你的系统出现[不支持开源字体](https://www.bilibili.com/video/BV1T6xkzjEX6/)的情况，可以参考[字体设置](https://github.com/IammyselfYBX/JLU_TLT/wiki/%E5%AD%97%E4%BD%93)进行编译。


## 2.编译
### \[推荐\] 使用latexmk
```bash
latexmk -f main.tex 
```

https://github.com/user-attachments/assets/d924c7a5-e1f0-4cb3-8320-bd9d696e0e1d

> 最终结果
> 文档主题在 [part](part) 下各文件。
> <details>
> <summary>
> 图例
> </summary>
> <img src="figures/module/cover.png" width="80%"/>
> </details>
> 

### xelatex
```bash
xelatex main.tex        # 第一轮：生成未解析的引用
bibtex main             # 处理参考文献
xelatex main.tex        # 第二轮：解析引用
makeindex main.idx      # 生成索引（如有）
xelatex main.tex        # 第三轮：最终定稿
```


# 相关项目
[吉林大学答辩Beamer模板](https://github.com/IammyselfYBX/JLUbeamer)

# 参考
- [吉林大学硕博学位论文LaTeX模板——jluthesis2020](https://github.com/maxuewei2/jluthesis2020)
- 本科毕业论文：[x86vk/JLU-CCST-Thesis](https://github.com/x86vk/JLU-CCST-Thesis)
- 硕士毕业论文：[jiafeng5513/JLU_Dissertation](https://github.com/jiafeng5513/JLU_Dissertation)
- [gbt7714](https://github.com/zepinglee/gbt7714-bibtex-style)

