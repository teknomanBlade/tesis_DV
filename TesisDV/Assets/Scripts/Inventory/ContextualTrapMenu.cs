using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ContextualTrapMenu : MonoBehaviour
{
    public GameObject Trap1;
    public Animator Trap1Anim;
    public GameObject Trap2;
    public Animator Trap2Anim;
    private float fadeDelay = 1.1f;
    private bool isFaded;
    private bool isActiveTrap1 = false;
    private bool isActiveTrap2 = false;
    // Start is called before the first frame update
    void Awake()
    {
        Trap1Anim = Trap1.GetComponent<Animator>();
        Trap2Anim = Trap2.GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void ActivatePanelTrap1()
    {
        if(!isActiveTrap1)
            StartCoroutine(DoFadeTrap1());
    }

    public void ActivatePanelTrap2()
    {
        if (!isActiveTrap2)
            StartCoroutine(DoFadeTrap2());
    }

    public IEnumerator DoFadeTrap1()
    {
        isActiveTrap1 = true;
        Trap1Anim.SetBool("HasFirstTrap", true);
        yield return new WaitForSeconds(1.5f);

        isActiveTrap1 = false;
    }
    public IEnumerator DoFadeTrap2()
    {
        isActiveTrap2 = true;
        Trap2Anim.SetBool("HasSecondTrap", true);
        yield return new WaitForSeconds(1.5f);

        isActiveTrap2 = false;
    }
    
}
