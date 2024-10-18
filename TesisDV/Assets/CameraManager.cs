using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraManager : MonoBehaviour
{
    public Camera PBROpaqueCamera;
    public Camera PBRTransparentCamera;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            PBROpaqueCamera.gameObject.SetActive(!PBROpaqueCamera.gameObject.activeSelf);
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            PBRTransparentCamera.gameObject.SetActive(!PBRTransparentCamera.gameObject.activeSelf);
        }
    }
}
