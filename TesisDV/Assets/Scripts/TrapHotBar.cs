using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapHotBar : MonoBehaviour
{
    [SerializeField] TrapSlot[] trapSlots;

    [SerializeField] private CanvasGroup _myCanvasGroup;
    private float fadeDelay = 1.1f;
    private bool isFaded;

    private void Awake()
    {
        _myCanvasGroup = GetComponent<CanvasGroup>();
        isFaded = true;
    }

    public void Fade()
    {
        StartCoroutine(DoFade(_myCanvasGroup.alpha, 1));
        isFaded = !isFaded;
    }
    public IEnumerator DoFade(float start, float end)
    {
        float counter = 0f;

        while (counter < fadeDelay)
        {
            counter += Time.deltaTime;
            _myCanvasGroup.alpha = Mathf.Lerp(start, end, counter / fadeDelay);

            yield return null;
        }
    }

    public void CheckRecipeRequirements(Inventory inventory)
    {
        if (GameVars.Values.BaseballLauncher.HasBaseballTrapItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[0].ActivateImage();
        }
        else
        {
            trapSlots[0].DeactivateImage();
        }

        if (GameVars.Values.MicrowaveForceFieldGenerator.HasMicrowaveForceFieldGeneratorItems(inventory))
        {
            if (isFaded)
            {
                Fade();
            }
            trapSlots[1].ActivateImage();
            GameVars.Values.HasMicrowaveTrapAppearedHotBar = true;
        }
        else
        {
            trapSlots[1].DeactivateImage();
        }

        if (GameVars.Values.SlowTrap.HasSlowTrapItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[2].ActivateImage();
            GameVars.Values.HasSlowingTrapAppearedHotBar = true;
        }
        else
        {
            trapSlots[2].DeactivateImage();
        }

        if (GameVars.Values.SlowTrap.HasNailFiringMachineItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[3].ActivateImage();
            GameVars.Values.HasDartsTrapAppearedHotBar = true;
        }
        else
        {
            trapSlots[3].DeactivateImage();
        }

        if (GameVars.Values.SlowTrap.HasElectricTrapItems(inventory))
        {
            if(isFaded)
            {
                Fade();
            }
            trapSlots[4].ActivateImage();
            GameVars.Values.HasElectricTrapAppearedHotBar = true;
        }
        else
        {
            trapSlots[4].DeactivateImage();
        }
    }

    
}
