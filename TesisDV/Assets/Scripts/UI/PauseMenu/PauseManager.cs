using UnityEngine;

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
