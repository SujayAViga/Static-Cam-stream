using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

public class CameraCapture : MonoBehaviour
{
    public Material rgbdMaterial;
    public Camera depthCamera;
    public RenderTexture targetTexture;
    //Wpublic GameObject plane;

    // Start is called before the first frame update
    void Start()
    {
        depthCamera.depthTextureMode = DepthTextureMode.Depth;
        //depthCamera.farClipPlane = 20f; //Draw distance
        //material = plane.GetComponent<Image>().material;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Debug.Log("Rendering from " + gameObject.name);
        // copies source renderTexture to material's _MainTex.
        // The material uses it shader to modify the _mainTex, and the resulting quad is copied back to the targetTexture
        Graphics.Blit(source, targetTexture, rgbdMaterial);
        // Copy the source to screen
        Graphics.Blit(targetTexture, destination);

        //Graphics.Blit(stream, targetTexture);
        //Graphics.Blit(source, targetTexture, material);
        //Graphics.Blit(source, destination);
    }
}
