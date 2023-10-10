using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using Newtonsoft.Json;
using System.Globalization;


public class StaticCamJsonGenerator : MonoBehaviour
{
    public Camera[] Cameras;
    private List<StaticCaptureInfo> CaptureList;
    private float near = 0.3f, far = 2250, width = 1920, height = 1080,orthoSize = 700;
    private string amsURL = "https://3dstreams-dev.expocitydubai.com:5443/vigastudios/streams/";

    private void Start()
    {
        CaptureList = new List<StaticCaptureInfo>();
        Cameras = FindObjectsOfType<Camera>();
        SaveCameraInfo();
        string jsonText = Newtonsoft.Json.JsonConvert.SerializeObject(CaptureList);
        System.IO.File.WriteAllText("D:/" + "/Static.json", jsonText);
        //Debug.Log(CaptureList);
    }

    void SaveCameraInfo()
    {
        for(int i = 0; i < Cameras.Length; i++)
        {
            StaticCaptureInfo CaptureInfo = new StaticCaptureInfo();
            CaptureInfo.streamName = Cameras[i].name;
            CaptureInfo.streamLink = amsURL + Cameras[i].name+".m3u8";
            CaptureInfo.ortho = orthoSize;
            CaptureInfo.near_plane = near;
            CaptureInfo.far_plane = far;
            CaptureInfo.rotateX = Cameras[i].transform.eulerAngles.x;
            CaptureInfo.rotateY = Cameras[i].transform.eulerAngles.y;
            CaptureInfo.rotateZ = Cameras[i].transform.eulerAngles.z;
            CaptureInfo.position = new float[] { Cameras[i].transform.position.x, Cameras[i].transform.position.y, Cameras[i].transform.position.z };
            //CaptureInfo.rotation = new float[] { Cameras[i].transform.rotation.x, Cameras[i].transform.rotation.y, Cameras[i].transform.rotation.z };
            CaptureInfo.width = width;
            CaptureInfo.height = height;
            CaptureList.Add(CaptureInfo);
        }
    }

    [System.Serializable]
    public class StaticCaptureInfo
    {
        public string streamName;
        public string streamLink;
        public float ortho;
        public float near_plane;
        public float far_plane;
        public float rotateY;
        public float rotateX;
        public float rotateZ;
        public float[] position;
        //public float[] rotation
        public float width;
        public float height;
        
    }
}
