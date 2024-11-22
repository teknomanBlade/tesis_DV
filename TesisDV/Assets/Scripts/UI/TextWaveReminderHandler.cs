using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TextWaveReminderHandler : MonoBehaviour
{
    public Animator anim;
    public bool IsReachedEventFirstTime;
    // Start is called before the first frame update
    void Start()
    {
        IsReachedEventFirstTime = false;
        StartCoroutine(ChangePassedTutorial());
    }

    // Update is called once per frame
    void Update()
    {
        /*if (IsReachedEventFirstTime)
            StartCoroutine(ChangePassedTutorial());*/
    }
    IEnumerator ChangePassedTutorial()
    {
        while (true) 
        {
            yield return new WaitForSeconds(120);
            if (IsReachedEventFirstTime)
                GameVars.Values.PassedTutorial = true;
        }
    }
    public void PrintEvent()
    {
        anim.SetBool("IsWaveReminder", false);
        GameVars.Values.PassedTutorial = false;
        IsReachedEventFirstTime = true;
    }
}
