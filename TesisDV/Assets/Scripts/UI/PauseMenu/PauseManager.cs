using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.UI;

public class PauseManager : MonoBehaviour
{
    public GameObject BtnRestart, BtnBackToMainMenu;
    private Coroutine FadeOutSceneCoroutine;
    private Coroutine FadeInSceneCoroutine;
    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Confined;
    }

    // Update is called once per frame
    void Update()
    {
        Sprite currentSpriteRestart = BtnRestart.GetComponent<Button>().image.sprite;

        if (currentSpriteRestart.name.Contains("Highlighted"))
        {
            Debug.Log("El botón está en estado Highlighted");
            //BtnRestart.GetComponent<RectTransform>().anchoredPosition = new Vector2(10f, 12f);
            BtnRestart.GetComponent<RectTransform>().sizeDelta = new Vector2(178f, 35f);
        }
        else if (currentSpriteRestart.name.Contains("Pressed"))
        {
            Debug.Log("El botón está en estado Pressed");
            //BtnRestart.GetComponent<RectTransform>().anchoredPosition = new Vector2(-325f, -12f);
            BtnRestart.GetComponent<RectTransform>().sizeDelta = new Vector2(178f, 35f);
        }
        else
        {
            Debug.Log("El botón está en estado Normal");
            //BtnRestart.GetComponent<RectTransform>().anchoredPosition = new Vector2(-315f, -12f);
            BtnRestart.GetComponent<RectTransform>().sizeDelta = new Vector2(160f,30f);
        }

        Sprite currentSpriteBackToMainMenu = BtnBackToMainMenu.GetComponent<Button>().image.sprite;

        if (currentSpriteRestart.name.Contains("Highlighted"))
        {
            Debug.Log("El botón está en estado Highlighted");
            BtnBackToMainMenu.GetComponent<RectTransform>().sizeDelta = new Vector2(178f, 35f);
        }
        else if (currentSpriteRestart.name.Contains("Pressed"))
        {
            Debug.Log("El botón está en estado Pressed");
            BtnBackToMainMenu.GetComponent<RectTransform>().sizeDelta = new Vector2(178f, 35f);
        }
        else
        {
            Debug.Log("El botón está en estado Normal");
            BtnBackToMainMenu.GetComponent<RectTransform>().sizeDelta = new Vector2(160f, 30f);
        }
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
