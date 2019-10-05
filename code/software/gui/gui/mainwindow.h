#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QDebug>
#include "PCIE.h"
#include "TERASIC_PCIE_mSGDMA.h"

#include <QGraphicsScene>
#include <QGraphicsView>
#include <QGraphicsItem>
 #include <QGraphicsPixmapItem>


#define DEMO_PCIE_IO_LED_ADDR		0x4000010
#define DEMO_PCIE_IO_BUTTON_ADDR	0x4000020
#define DEMO_PCIE_MEM_ADDR			0x00000000
#define ADDR_BAR1                   0x4
#define MEM_SIZE			(512*1024) //512KB
namespace Ui {
class MainWindow;
}

class QCamera;
class QCameraViewfinder;
class QCameraImageCapture;
class QVBoxLayout;

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    bool TEST_DMA_MEMORY(PCIE_HANDLE hPCIe);
    explicit MainWindow(QWidget *parent = nullptr);
    void my_func(int requestId, const QImage& img);
    bool load_frame_to_fpga(PCIE_HANDLE hPCIe, int requestId, QImage &img);
    QImage read_frame_from_fpga(PCIE_HANDLE hPCIe,  QImage &img);
    QImage getImage() const;
    ~MainWindow();

private slots:
  //  void on_testPCIe_clicked();
  //  void updateTime(); //Слот для обновления времени на экране
    void on_capture_button_clicked();

    void on_horizontalSlider_valueChanged(int value);

private:
    Ui::MainWindow *ui;
     QTimer *tmr; //Адресная переменная таймера
    QCamera *mCamera;
    QCameraViewfinder *mCameraViewfinder ;
    QCameraImageCapture *mCameraImageCapture;
    QVBoxLayout *mLayout;

     QGraphicsPixmapItem *enemyItem;
    QGraphicsScene *scene;
    QGraphicsScene *scene2;
    QImage img_in, img_in_frame_1, img_in_frame_2, mImage, img2fpga, img_read_fpga;
    QImage img_out2_1, img_out2_2;
    QImage img_res;
    QPixmap image;
    QPixmap image_out;
    quint8 *pFrameWrite_1;
    quint8 *pFrameWrite_2;
    quint8 *pFrameWrite;
    quint8 *pFrameRead;
   // QRgb rgb1;
    unsigned int SizeFrame;
    unsigned int height_frame;
    unsigned int width_frame;

    PCIE_HANDLE hPCIE;
    bool bPass;
    void *lib_handle;

};




#endif // MAINWINDOW_H
