using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrapHotBar : MonoBehaviour
{
    [SerializeField] Slot[] trapSlots;

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
            //Activar slotbaseball
        }

        if (GameVars.Values.BaseballLauncher.HasTVTrapItems(inventory))
        {
            //Activar slotTV
        }
    }
}
