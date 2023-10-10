using System.Diagnostics;
using System.IO;
using UnityEngine;

public class FFmpegStreamer : MonoBehaviour
{
    public RenderTexture renderTexture;
    //Texture2D texture;
    string ffmpegPath = Application.streamingAssetsPath + "/ffmpeg/bin/ffmpeg.exe";
    //string outputUrl = "rtmp://20.21.121.81/LiveApp/unitystream";
    private string outputUrl = "rtmp://3dstreams-dev.expocitydubai.com/vigastudios/";
    [SerializeField]
    private string streamID;
    int frameRate = 30;
    // int bitrate = 2000;

    private Process ffmpegProcess;
    private BinaryWriter ffmpegInput;
    Texture2D frame;
    void Start()
    {
        frame = new Texture2D(renderTexture.width, renderTexture.height, TextureFormat.RGBA32, 1, false);
        //UnityEngine.Debug.Log(System.IO.Directory.GetCurrentDirectory()+"  kela");
        // Start the FFmpeg process
        ffmpegProcess = new Process();
        ffmpegProcess.StartInfo.FileName = ffmpegPath;
        //ffmpegProcess.StartInfo.Arguments = $"-y -f rawvideo -vcodec rawvideo -pix_fmt rgba -s {renderTexture.width}x{renderTexture.height} -r {frameRate} -i - -vf \"vflip\" -c:v libx264 -preset ultrafast -f flv {outputUrl+streamID}";
        //ffmpegProcess.StartInfo.Arguments = $"-y -f rawvideo -vcodec rawvideo -pix_fmt rgba -s {renderTexture.width}x{renderTexture.height} -r {frameRate} -i - -c:v libx264 -pix_fmt yuv420p -preset ultrafast -b:v {bitrate}k -maxrate {bitrate}k -bufsize {bitrate * 2}k -f flv {outputUrl}";
        ffmpegProcess.StartInfo.Arguments = $"-y -f rawvideo -vcodec rawvideo -pix_fmt rgba -s {renderTexture.width}x{renderTexture.height} -r {frameRate} -i - -vf \"vflip\" -c:v libx264 -pix_fmt yuv420p -preset ultrafast -f flv {outputUrl + streamID}";
        ffmpegProcess.StartInfo.CreateNoWindow = true;
        ffmpegProcess.StartInfo.UseShellExecute = false;
        ffmpegProcess.StartInfo.RedirectStandardInput = true;

        ffmpegProcess.Start();
        //// Open the FFmpeg process's standard input stream for writing
        ffmpegInput = new BinaryWriter(ffmpegProcess.StandardInput.BaseStream);
    }

    void OnDestroy()
    {
        if (ffmpegProcess != null) {
            // Close the FFmpeg process's standard input stream and wait for it to exit
            ffmpegInput.Close();
            ffmpegProcess.WaitForExit();
        }
    }

    void FixedUpdate()
    {
        RenderTexture.active = renderTexture;
        frame.ReadPixels(new Rect(0, 0, renderTexture.width, renderTexture.height), 0, 0, false);
        frame.Apply();
        byte[] pixels = frame.GetRawTextureData();
        ffmpegInput.Write(pixels);
        //SaveToPng(frame);
    }
}
