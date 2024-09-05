using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.UI;

public class PauseManager : MonoBehaviour
{
    public GameObject BtnRestart, BtnBackToMainMenu;
    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Confined;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void Restart() 
    {
        GameVars.Values.Player.ActiveFadeOutEffect("Restart");
    }

    public void BackToMainMenu()
    {
        GameVars.Values.Player.ActiveFadeOutEffect("BackToMainMenu");
    }

}
