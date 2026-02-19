import 'package:flutter/services.dart';
import 'package:master_code/source/constant/default_constant.dart';
import 'package:master_code/view_model/payroll_provider.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import '../../model/payroll/payroll_details_model.dart';
import 'package:intl/intl.dart';

class PaySlip {
  final PayrollDetailsModel data;
  final String hra;
  final String basicDA;
  final String totalEarn;
  final String totalDec;
  final String netAmount;
  final String lop;
  final int addedAmount;
  final int lessAmount;
  final PayrollProvider payrollProvider;
  final String totalLeaveDays;
  final String fixedMonthLeaves;
  PaySlip(this.data, this.hra, this.basicDA, this.totalEarn, this.netAmount, this.totalDec, this.addedAmount, this.lessAmount, this.lop, this.payrollProvider, this.totalLeaveDays, this.fixedMonthLeaves
      );

  var color=const PdfColor.fromInt(0xff1A237E);
  var formatter = NumberFormat('#,##,000');

  Future<void> generateImage() async {
    final pdf = Document();
    // final imageByteData = await rootBundle.load('assets/images/logo.png');
    final ttf = await rootBundle.load("assets/font/times.ttf");
    // final imageList = imageByteData.buffer
    //     .asUint8List(imageByteData.offsetInBytes, imageByteData.lengthInBytes);

    // final image =MemoryImage(imageList);

    var color=const PdfColor.fromInt(0xffEEEECD);


    var  marginLeft = 2.0;
    var marginRight = 2.0;
    var marginTop = 2.0;
    var marginBottom = 2.0;
    final pageTheme = PageTheme(
      //theme:myTheme,
      pageFormat: PdfPageFormat.a4,

      orientation: PageOrientation.portrait,
      margin:EdgeInsets.fromLTRB(
        marginLeft,
        marginTop,
        marginRight,
        marginBottom,
      ),
      buildBackground:(context){
        if (context.pageNumber == 1){
          return Text("");
        } else {
          return Text("");
        }
      },
    );

    pdf.addPage(
      Page(
        pageTheme:pageTheme,
        build:(context){
          return  Center(
              child: Container(
                  child:Column(
                      children:[
                        SizedBox(height: 20,),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(constValue.appName,style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),fontBold: Font.times())),
                              SizedBox(height: 10,),
                              Text("Salary Slip For - ${payrollProvider.month} ${DateTime.now().year}",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),
                              SizedBox(height: 10,),
                              Text("${payrollProvider.startDate} to ${payrollProvider.endDate}",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),
                            ]
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: 570,
                          height: 2,
                            color: color
                        ),
                        Container(
                          width: 570,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    children: [
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Name :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("Designation :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("Department :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("Date Of Joining :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),))
                                          ]
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("${data.fName}",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text(data.roleId.toString(),style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text(data.roleId.toString(),style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("${data.doj}",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),))
                                          ]
                                      ),
                                    ]
                                ),
                                Row(
                                    children: [
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Total Month Days :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("Working Days :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("Present Days :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("Absent Days :",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),))
                                          ]
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(payrollProvider.noOfWorkingDay.text,style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("${int.parse(payrollProvider.noOfWorkingDay.text)-fixedMonthLeaves.length}",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text("${data.dutyDays}",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),SizedBox(height: 10,),
                                            Text(totalLeaveDays,style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),))
                                          ]
                                      ),
                                    ]
                                )
                              ]
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          width: 570,
                          child: Table(
                            border:TableBorder.all(
                                color: color
                            ),
                            children:[
                              TableRow(
                                  children:[
                                    Text("\nEarnings\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),),textAlign: TextAlign.center),
                                    Text("\nEmployee Deduction\n\n", style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),),textAlign: TextAlign.center),
                                  ]
                              ),
                              TableRow(
                                  children: [
                                    Table(
                                      border:TableBorder.all(
                                          color: color
                                      ),
                                      children:[
                                        TableRow(
                                            children:[
                                              Text("\n  Components\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),
                                              Text("\n  Amount\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf),)),
                                            ]
                                        ),
                                        TableRow(
                                            children:[
                                              Text("\n  Salary\n\n",style: TextStyle(
                                                font:Font.ttf(ttf),
                                              ),),
                                              Text("\n  ${data.salary.toString()=="null"||data.salary.toString()=="0"?"0":payrollProvider.formatter.format(int.parse(data.salary.toString()))}\n\n",style: TextStyle(
                                                font:Font.ttf(ttf),
                                              ),),
                                            ]
                                        ),
                                        TableRow(
                                            children:[
                                              Text("\n  Basic+DA\n\n",style: TextStyle(
                                                font:Font.ttf(ttf),
                                              ),),
                                              Text("\n  ${basicDA.toString()=="0"?"0":payrollProvider.formatter.format(int.parse(basicDA.toString()))}\n\n",style: TextStyle(
                                                font:Font.ttf(ttf),
                                              ),),
                                            ]
                                        ),
                                        TableRow(
                                            children:[
                                              Text("\n  HRA\n\n",style: TextStyle(
                                                font:Font.ttf(ttf),
                                              ),),
                                              Text("\n  ${hra.toString()=="0"?"0":payrollProvider.formatter.format(int.parse(hra.toString()))}\n\n",style: TextStyle(
                                                font:Font.ttf(ttf),
                                              ),),
                                            ]
                                        ),
                                      ],),
                                    if(data.cat![0].category.toString()!="null")
                                      Container(
                                        child: ListView.builder(
                                            itemCount:data.cat!.length,
                                            itemBuilder: (context,i){
                                              return Table(
                                                border:TableBorder.all(
                                                    color: color
                                                ),
                                                children:[
                                                  if(i==0)
                                                  TableRow(
                                                      children:[
                                                        Text("\n  Components\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf))),
                                                        Text("\n  Amount\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf))),
                                                      ]
                                                  ),
                                                  TableRow(
                                                      children:[
                                                        Container(
                                                          width:80,
                                                          child: Text("\n  ${data.cat![i].category}\n\n",style: TextStyle(
                                                            font:Font.ttf(ttf),
                                                          ),)
                                                        ),
                                                        if(data.cat![i].categoryType.toString()!="3")
                                                          Container(
                                                            width:80,
                                                            child: Text("\n  ${formatter.format(int.parse(data.cat![i].categoryAmount.toString()))}\n\n",style: TextStyle(
                                                              font:Font.ttf(ttf),
                                                            ),),
                                                        ),
                                                        if(data.cat![i].categoryType.toString()=="3")
                                                          Container(
                                                            width:80,
                                                            child: Text("\n  ${data.cat![i].categoryAmount.toString()} ${data.cat![i].categoryAmount.toString()=="1"?"Day":"Days"}\n( ${formatter.format(lop)} )\n\n",style: TextStyle(
                                                              font:Font.ttf(ttf),
                                                            ),),
                                                        ),
                                                      ]
                                                  ),
                                                  if(i==data.cat!.length-1)
                                                    TableRow(
                                                        children:[
                                                          Text("\n  Charges\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf))),
                                                          Text("\n  ${lessAmount!=0?formatter.format(lessAmount):"0"}\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf))),
                                                        ]
                                                    ),
                                                  if(i==data.cat!.length-1)
                                                    TableRow(
                                                        children:[
                                                          Text("\n  Incentive\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf))),
                                                          Text("\n  ${addedAmount!=0?formatter.format(addedAmount):"0"}\n\n",style: TextStyle(fontWeight: FontWeight.bold,font:Font.ttf(ttf))),
                                                        ]
                                                    )
                                                ],);
                                            }),
                                      ),

                                  ]),
                              TableRow(
                                  children:[
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:"\n  Total Earnings : ",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                          TextSpan(
                                            text: "  ${totalEarn.toString()=="0"?"0":payrollProvider.formatter.format(int.parse(totalEarn.toString()))}\n\n",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:"\n  Total Deductions : ",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                          TextSpan(
                                            text: "  ${totalDec.toString()=="0"?"0":payrollProvider.formatter.format(int.parse(totalDec.toString()))}\n\n",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                              ),
                            ],),
                        ),
                        Container(
                          width: 570,
                          child: Table(
                            border:TableBorder.all(
                                color: color
                            ),
                            children:[
                              TableRow(
                                  children:[
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: "\n  Net Amount : ",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                          TextSpan(
                                            text: "${netAmount.toString()=="0"?"0":payrollProvider.formatter.format(int.parse(netAmount.toString()))}\n\n",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: "\n  Net Amount in words : ",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                          TextSpan(
                                            text: "${NumberToWordsEnglish.convert(int.parse(netAmount.contains("-")?"0":netAmount)).toString()} \n\n",
                                            style: TextStyle(
                                              font:Font.ttf(ttf),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                              ),
                            ],),
                        ),
                        SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "\nRO: ",
                                style: TextStyle(
                                  font:Font.ttf(ttf),
                                ),
                              ),
                              TextSpan(
                                text: "1382nd & 3rd Floor Gaffar Market Karol Bagh Delhi, Delhi, In\n\n",
                                style: TextStyle(
                                  font:Font.ttf(ttf),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(color: color,width: 570,height: 2),
                        SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: "\nNote:",
                                style: TextStyle(
                                  font:Font.ttf(ttf),
                                ),
                              ),
                              TextSpan(
                                text: "This is a Computer Generated Slip and does not require signature\n\n",
                                style: TextStyle(
                                  font:Font.ttf(ttf),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                  )
              )
          );
        },
      ),
    );
    // controllers.pdfDownloadCtr.reset();
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async{
          try {
            return pdf.save();
          } catch (e){
            // print("Error during PDF generation: $e");
            return Uint8List(0); // Return an empty Uint8List to indicate failure
          }
        }
      //=> pdf.save()
    );
  }
}