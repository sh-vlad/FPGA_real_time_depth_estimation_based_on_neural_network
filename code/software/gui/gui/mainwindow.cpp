#include "mainwindow.h"
#include <QCamera>
#include <QCameraViewfinder>
#include <QCameraImageCapture>
#include <QVBoxLayout>
#include <qimage.h>
#include <qpixmap.h>
#include <qgraphicsscene.h>
#include <qstring.h>
#include <QDialog>
#include <math.h>
#include <QCameraInfo>
Q_DECLARE_METATYPE(QCameraInfo)
#include <QTimer>
#include <QTime>

#include <QTimer>
#include <QTime>
#include "ui_mainwindow.h"
MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    lib_handle = PCIE_Load();
   if (!lib_handle)
       ui->lineEdit->setText("0");

    hPCIE = PCIE_Open(DEFAULT_PCIE_VID, DEFAULT_PCIE_DID, 0);
    if (!hPCIE)
    {
       ui->lineEdit->setText("00");
       // connect(mCameraImageCapture, &QCameraImageCapture::imageCaptured, this,&MainWindow::my_func);
    }

    pFrameWrite_1 = new quint8[224*224*3];
    pFrameWrite_2 = new quint8[224*224*3];
    pFrameRead  = new quint8[224*224*3];
     scene = new QGraphicsScene(this);
     scene2 = new QGraphicsScene(this);
    tmr = new QTimer();

    tmr->setInterval(1000);

    tmr->start();
    QCamera();
 //
    //mCamera = new QCamera(this);
  //   mCamera = new QCamera(cameraInfo);
    //const QList<QCameraInfo> cameras = QCameraInfo::availableCameras();
 //  const QCameraInfo &cameraInfo;
   // ui->lineEdit->setText(QString::number(QCameraInfo::availableCameras().count()));

  //  cameras.value(1);
    QString name_usb_camera = "@device:pnp:\\\\?\\usb#vid_0c45&pid_62c0&mi_00#6&b4e379c&0&0000#{65e8773d-8f56-11d0-a3b9-00a0c9223196}\\global";
   // mCamera = new QCamera(QCameraInfo::availableCameras().first());

    const QList<QCameraInfo> availableCameras = QCameraInfo::availableCameras();
    for (const QCameraInfo &cameraInfo : availableCameras)
    {
     //  if(cameraInfo.deviceName()=="@device:pnp:\\\\?\\usb#vid_0c45&pid_62c0&mi_00#6&b4e379c&0&0000#{65e8773d-8f56-11d0-a3b9-00a0c9223196}\\global")
      //       mCamera = new QCamera(cameraInfo.availableCameras().last());
        ui->lineEdit->setText(QString::number(QCameraInfo::availableCameras().count()));
        ui->lineEdit_2->setText(cameraInfo.deviceName());
        //qDebug()<<cameraInfo.deviceName();
    }
    mCamera = new QCamera(this);
   mCameraViewfinder = new QCameraViewfinder(this);
   mCameraImageCapture = new QCameraImageCapture(mCamera, this);

   mCameraImageCapture->setCaptureDestination(QCameraImageCapture::CaptureToFile);
  // mCamera->setViewfinder(mCameraViewfinder);
  // const QCameraInfo &a;
 //  qDebug()<<QCameraInfo::availableCameras().count();
  //  qDebug()<<a.deviceName();
   //QCameraInfo info = actions()



   //  for (const QCameraInfo &cameraInfo : availableCameras) {



   //mLayout = new QVBoxLayout;
   mCamera->start();
    connect(mCameraImageCapture, &QCameraImageCapture::imageCaptured, this,&MainWindow::my_func);
    connect(tmr, SIGNAL(timeout()), this, SLOT(on_capture_button_clicked()));
    // connect(m_imageCapture.data(), &QCameraImageCapture::CaptureToBufferimageCaptured, this, &Camera::processCapturedImage);
   //mLayout->addItem(mCameraViewfinder);

      //  camera->setViewfinder(ui ->viewfinder);
      //  camera->start();
}

MainWindow::~MainWindow()
{
    delete ui;
    delete tmr;
    delete []pFrameWrite_1;
    delete []pFrameWrite_2;
    delete []pFrameRead;
    PCIE_Close(hPCIE);
    PCIE_Unload(lib_handle);
}
bool MainWindow::TEST_DMA_MEMORY(PCIE_HANDLE hPCIe)
{
    bool bPass = true;
    int i;
    const int nTestSize = 512;
    const PCIE_LOCAL_ADDRESS LocalAddr = ADDR_BAR1;
    qint32 *pWrite;
    char szError[256];

    pWrite = (qint32 *) malloc(nTestSize);
    if (!pWrite ) {
        bPass = false;
        sprintf(szError, "DMA Memory:malloc failed\r\n");
    }


     for (i = 0; i < 512; i++)
         *(pWrite + i) = i;
    // write test pattern
   if (bPass) {
       bPass = PCIE_DmaWrite(hPCIe, 0x08000000, pWrite, nTestSize*4);
       if (!bPass)
           sprintf(szError, "DMA Memory:PCIE_DmaWrite failed\r\n");
   }

    // free resource
    if (pWrite)
       free(pWrite);

     if (!bPass)
        printf("%s", szError);
    else
        printf("DMA-Memory (Size = %d byes) pass\r\n", nTestSize);

    return bPass;
}
bool MainWindow::load_frame_to_fpga(PCIE_HANDLE hPCIe, int requestId, QImage &img)
{
    height_frame  = static_cast<unsigned int>(img.height()); //высота исходного изображения
    width_frame   = static_cast<unsigned int>(img.width());  //ширина исходного изображения=
    SizeFrame = height_frame*width_frame*3;// in bytes
    QRgb rgb1;
    //rgb1 = qRgb(r, g, b);
    if(requestId%2==0)
         pFrameWrite = pFrameWrite_1;
    else
         pFrameWrite = pFrameWrite_2;

     for (unsigned int i = 0; i < height_frame; i++)
     {
         for(unsigned int j = 0; j < width_frame; j++)
         {
             rgb1 = img.pixel(static_cast<int>(i),static_cast<int>(j));
             *(pFrameWrite + 3*(i*height_frame +j) +0) = static_cast<quint8>( qRed(rgb1));
             *(pFrameWrite + 3*(i*height_frame +j) +1) = static_cast<quint8>( qGreen(rgb1));
             *(pFrameWrite + 3*(i*height_frame +j) +2) = static_cast<quint8>( qBlue(rgb1));
            // *(pFrameWrite + 4*(i*height_frame +j) +3) =0;
         }
     }

     // проверка: загрузился ли предыдущий кадр
     // если да, то PCIE_DmaWrite
    // write test pattern
   if (bPass)
       bPass = PCIE_DmaWrite(hPCIe, 0x08000000, pFrameWrite, SizeFrame);


    return bPass;
}

QImage MainWindow::read_frame_from_fpga(PCIE_HANDLE hPCIe,  QImage &img)
{
    unsigned int height  = 224;//static_cast<unsigned int>(img.height()); //высота исходного изображения
    unsigned int width   = 224;//static_cast<unsigned int>(img.width());  //ширина исходного изображения=
    bool bPass = true;
    QImage imgTemp2= img;
    unsigned int SizeFrame = height*width*3;// in bytes
    quint8 r,g,b;
    QRgb rgb1; //исходное изображение

    // write test pattern
   if (bPass)
       bPass = PCIE_DmaRead(hPCIe, 0x07000000, pFrameRead, SizeFrame);
   for (unsigned int i = 0; i < height; i++)
   {
       for(unsigned int j = 0; j < width; j++)
       {
           r =*(pFrameRead + 3*(i*height +j) +0);
           g =*(pFrameRead + 3*(i*height +j) +1);
           b =*(pFrameRead + 3*(i*height +j) +2);
           rgb1 = qRgb(r, g, b);
           imgTemp2.setPixel(static_cast<int>(i),static_cast<int>(j),rgb1);
       }
   }

    return imgTemp2;
}
/*
void MainWindow::on_testPCIe_clicked()
{
    bool bPass;
    void *lib_handle;
    lib_handle = PCIE_Load();
    printf("lib_handle = %d\n",lib_handle);
   if (!lib_handle) {
        printf("PCIE_Load failed!\r\n");
            qDebug()<<"Error";
   }

    PCIE_HANDLE hPCIE;
    bool bQuit = false;
    int nSel;

    printf("== Terasic: PCIe Demo Program ==\r\n");
    hPCIE = PCIE_Open(DEFAULT_PCIE_VID, DEFAULT_PCIE_DID, 0);
    if (!hPCIE){
       printf("PCIE_Open failed\r\n");
       ui->lineEdit->setText("0");
    }
    else
    {
        printf("good!\n");
        bPass = TEST_DMA_MEMORY(hPCIE);
        if(bPass)
             ui->lineEdit->setText("1");
        else
            ui->lineEdit->setText("00");


    }

    //bPass = TEST_DMA_MEMORY(hPCIE);
    //TEST_LED(hPCIE);
    PCIE_Close(hPCIE);
    PCIE_Unload(lib_handle);
}
*/
int Sat(int x)
{
    return x > 255 ? 255 : x < 0 ? 0 : x;
}
//интерполирующая функция///
double Z(int G[][2],double x, double y)
{
    int b1,b2,b3,b4;
    b1=G[0][0];
    b2=G[1][0]-G[0][0];
    b3=G[0][1]-G[0][0];
    b4=G[0][0]-G[1][0]-G[0][1]+G[1][1];
    return b1+b2*x+b3*y+b4*x*y;
}
// алгоритм интерполяции
QImage Bilinear_interpolation(const QImage imgOrig,const QImage img_out, int new_H,int new_W)
{
    QImage imgTemp  = imgOrig;
    QImage imgTemp2 = img_out;
    QRgb rgb1; //исходное изображение
        QRgb rgb2;//новое изображение
    int old_Height  = imgTemp.height(); //высота исходного изображения
    int old_Width   = imgTemp.width();  //ширина исходного изображения
    //qDebug()<<old_Height;
    double old_x,old_y;
    int X,Y;
    int G_r[2][2];
    int G_g[2][2];
    int G_b[2][2];
    double x,y;
    for(int new_y=0; new_y<new_H; new_y++)
    {
        for(int new_x=0;new_x<new_W; new_x++)
        {
            /*step 1.   */
            old_x=new_x*static_cast<double>(old_Width-1)/(new_W-1);
            old_y=new_y*static_cast<double>(old_Height-1)/(new_H-1);
            /*step 2    */
            x=static_cast<double>((new_x*(old_Width-1))%(new_W-1))/(new_W-1);
            y=static_cast<double>((new_y*(old_Height-1))%(new_H-1))/(new_H-1);
            /*step 3    */
            for(int i=-1;i<1;i++)
            {
                for(int j=-1;j<1;j++)
                {
                    Y= static_cast<int>(floor(old_y + i-1));
                    X= static_cast<int>(floor(old_x +j-1));
                    X = X > old_Width  ? old_Width-1 : X < 0 ? 0 : X;
                    Y = Y > old_Height ? old_Height-1 : Y < 0 ? 0 : Y;
                    rgb1 =imgTemp.pixel(X,Y);
                    G_r[i+1][j+1] = qRed(rgb1);
                    G_g[i+1][j+1] = qGreen(rgb1);
                    G_b[i+1][j+1] = qBlue(rgb1);
                }
            }
            int r = Sat(static_cast<int>(Z(G_r,x,y)));
            int g = Sat(static_cast<int>(Z(G_g,x,y)));
            int b = Sat(static_cast<int>(Z(G_b,x,y)));
            rgb2 = qRgb(r,g,b);
            imgTemp2.setPixel(new_x,new_y,rgb2);
        }
    }
    return imgTemp2;
}

int Clip(int x,int x_min,int x_max)
{
    if(x < x_min)
        return x_min;
    else if(x > x_max)
        return x_max;
    else
        return x;
}
QImage MainWindow::getImage() const
{
    return mImage;
}
void MainWindow::my_func(int requestId, const QImage& img)
{
    QRgb rgb_res, rgb_in_1, rgb_in_2;
    // int _w = .width()/2;

    img_in =img;
    int ImgHeightIn = img_in.height();
    int ImgWidthIn = img_in.width();
   //// ui->
    ui->lineEdit_H->setText(QString::number(ImgHeightIn));
    ui->lineEdit_W->setText(QString::number(ImgWidthIn));
    ImgWidthIn/=2;
//     qDebug()<<"ImgWidthIn = "<<ImgWidthIn;
    img_in_frame_1 = img_in.scaled(ImgWidthIn,ImgHeightIn);
    img_in_frame_2 = img_in.scaled(ImgWidthIn,ImgHeightIn);
    ui->lineEdit111->setText("1");
    for(int w=0; w< ImgWidthIn; w++)
    {
        for(int h=0;h<ImgHeightIn; h++)
        {
            rgb_in_1 =img_in.pixel(w,h);
            rgb_in_2 =img_in.pixel((w +ImgWidthIn ),h);
            img_in_frame_1.setPixel(w, ImgHeightIn-h, rgb_in_1);
            img_in_frame_2.setPixel(w, ImgHeightIn-h, rgb_in_2);
        }
    }
    ui->lineEdit111->setText("2");
    img_out2_1 = img_in.scaled(350,350);//img_in.scaled(350,350);
    img_out2_2 = img_in.scaled(350,350);
    img_res  = img_in.scaled(350,350);
    img2fpga =img_in.scaled(224,224);
    img_read_fpga = img_in.scaled(224,224);
    ui->lineEdit111->setText("3");
    //img_out2 = Bilinear_interpolation(img_in,img_out2, 350,350);
    img_out2_1 = Bilinear_interpolation(img_in_frame_1,img_out2_1, 350,350);
    img_out2_2 = Bilinear_interpolation(img_in_frame_2,img_out2_2, 350,350);
    ui->lineEdit111->setText("4");
    img2fpga = Bilinear_interpolation(img_in,img2fpga, 224,224);
    ui->label_2->setPixmap(QPixmap::fromImage(img_out2_1));
    ui->label_5->setPixmap(QPixmap::fromImage(img_out2_2));
    ui->lineEdit111->setText("5");
    if(hPCIE)
        bPass = load_frame_to_fpga(hPCIE, requestId, img2fpga);
    else {
        bPass =0;
    }
    if(bPass)
        ui->lineEdit->setText("bPass=true");
     else
        ui->lineEdit->setText("00");

    if(hPCIE)
    {
        img_read_fpga = read_frame_from_fpga(hPCIE,img_read_fpga);
        img_res = Bilinear_interpolation(img_read_fpga,img_res, 350,350);
        ui->label_3->setPixmap(QPixmap::fromImage(img_res));
        ui->lineEdit->setText("read");
    }

}
void MainWindow::on_capture_button_clicked()
{

   // mCameraImageCapture ->setCaptureDestination(QCameraImageCapture::CaptureToBuffer);
    mCameraImageCapture->capture();
}

void MainWindow::on_horizontalSlider_valueChanged(int value)
{
    tmr->setInterval(1001 - 100*(value));
}
