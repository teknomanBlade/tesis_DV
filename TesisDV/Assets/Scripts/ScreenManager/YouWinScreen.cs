using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class YouWinScreen : MonoBehaviour, IScreen
{

    // Start is called before the first frame update
    void Start()
    {

    }

    public void Activate()
    {

    }

    public void Deactivate()
    {
        
    }

    public string Free()
    {
        Destroy(gameObject);
        return "YouWin";
    }

    public void ActiveScreen()
    {
        gameObject.SetActive(true);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            SceneManager.LoadScene("MainFloor_Upgrade");
        }
    }
}
