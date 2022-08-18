using System.Collections;
using System.Collections.Generic;
using UnityEngine.SceneManagement;
using UnityEngine;

public class MainScreen : MonoBehaviour
{
    public GameObject controls;
    public GameObject credits;
    public GameObject houseStructure;
    private AudioSource _as;
    // Start is called before the first frame update
    void Awake()
    {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        _as = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void BtnPlay()
    {
        _as.Stop();
        SceneManager.LoadScene(1);
    }

    public void BtnControls()
    {
        Debug.Log("CLICK CONTROLS?");
        houseStructure.SetActive(false);
        controls.SetActive(!controls.activeSelf);
    }

    public void BtnCredits()
    {
        Debug.Log("CLICK CREDITS?");
        houseStructure.SetActive(false);
        credits.SetActive(!credits.activeSelf);
    }
    public void BtnBackCredits()
    {
        houseStructure.SetActive(true);
        credits.SetActive(!credits.activeSelf);
    }

    public void BtnBackControls()
    {
        houseStructure.SetActive(true);
        controls.SetActive(!controls.activeSelf);
    }
    public void BtnQuit()
    {
        Application.Quit();
    }

}
