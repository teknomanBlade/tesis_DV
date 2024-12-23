using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class CatDistanceBar : MonoBehaviour, IRoundChangeObserver
{
    private Slider _mySlider;
    private float _maxDistance;
    private float _dangerThreshold;
    private float _currentDistance = 0;
    private float _wittsAmount = 0;
    private float _graysAmount = 0;
    private Image _fillImage;
    public GameObject Fill;
    public Text GraysAmountPerWaveText;
    public Text WittsAmountText;
    public Text WittsAmountTextUpdatesPurchase;
    public Animator GraysAmountPerWaveTextAnim { get; private set; }
    public Text RoundText;
    public Text RestWaveTimeText;
    public Coroutine ReminderMessageCoroutine;
    public GameObject TxtWaveReminder;
    public Animator TxtWaveReminderAnim;
    public Animator _animCatDistanceBar;
    public Animator RestWaveTimeAnim { get; private set; }
    public Animator RoundTextAnim { get; private set; }
    public float _valueToChange { get; private set; }

    void Start()
    {
        _mySlider = GetComponent<Slider>();
        //RoundText = GetComponentsInChildren<Text>().Where(x => x.gameObject.name.Equals("TxtRound")).FirstOrDefault();
        RoundTextAnim = RoundText.GetComponent<Animator>();
        RoundTextAnim.SetBool("IsNewRound", false);
        //GraysAmountPerWaveText = GetComponentsInChildren<Text>().Where(x => x.gameObject.name.Equals("TxtGrayAmountPerWave")).FirstOrDefault();
        GraysAmountPerWaveTextAnim = GraysAmountPerWaveText.GetComponentInChildren<Image>().gameObject.GetComponent<Animator>();
        //RestWaveTimeText = GetComponentsInChildren<Text>().Where(x => x.gameObject.name.Equals("TxtRestWaveTime")).FirstOrDefault();
        RestWaveTimeAnim = RestWaveTimeText.gameObject.GetComponent<Animator>();
        _animCatDistanceBar = GetComponent<Animator>();
        GameVars.Values.WaveManager.AddObserver(this);
        GameVars.Values.WaveManager.OnRoundChanged += RoundChanged;
        GameVars.Values.WaveManager.OnTimeWaveChange += TimeWaveChanged;
        GameVars.Values.WaveManager.OnRoundStartEnd += RoundStartEnd;
        GameVars.Values.WaveManager.OnGrayAmountChange += GrayAmountChanged;
        TxtWaveReminderAnim = TxtWaveReminder.gameObject.GetComponent<Animator>();
        GameVars.Values.Inventory.OnWittsAmountChanged += WittsAmountChanged;
        _fillImage = Fill.GetComponent<Image>();
        _maxDistance = GameVars.Values.GetCatDistance();
        _dangerThreshold = _maxDistance * 0.20f;
        //54
        _mySlider.maxValue = _maxDistance; //_maxDistance;
        _mySlider.minValue = 1;
        _currentDistance = _maxDistance;
        _mySlider.value = _currentDistance;
        ReminderMessageCoroutine = StartCoroutine(ShowReminderOfWaveBringerKey());
    }
    

    IEnumerator ShowReminderOfWaveBringerKey()
    {
        while (true) 
        {
            yield return new WaitForSeconds(120);
            if (GameVars.Values.PassedTutorial)
            {
                TxtWaveReminder.GetComponentInChildren<Text>().text = "Remember that you can Press 'Enter' to send a wave.";
                TxtWaveReminderAnim.SetBool("IsWaveReminder", true);
            }
        }
    }
    
    public void PlayFadeIn()
    {
        _animCatDistanceBar.SetBool("IsFadeIn", true);
    }
    public void PlayFadeOut()
    {
        _animCatDistanceBar.SetBool("IsFadeIn", false);
    }

    private void RoundChanged(int newVal)
    {
        RoundText.text = "Round: " + newVal;
        StartCoroutine(ShowAnimRoundChanged());
    }

    private void RoundStartEnd(bool roundStart)
    {
        RestWaveTimeAnim.SetBool("InRound", roundStart);
    }

    private void TimeWaveChanged(float newVal)
    {
        RestWaveTimeText.text = "The grays are coming... ";
    }

    private void WittsAmountChanged(float newVal)
    {
        StartCoroutine(LerpWittsValue(newVal, 1f));
        //Aplicar animación.
    }
    IEnumerator LerpWittsValue(float endValue, float duration)
    {
        float time = 0;
        float startValue = _wittsAmount;

        while (time < duration)
        {
            _wittsAmount = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;
            WittsAmountText.text = "X " + Math.Round(_wittsAmount,2).ToString("F0");
            WittsAmountTextUpdatesPurchase.text = "X " + Math.Round(_wittsAmount,2).ToString("F0");
            yield return null;
        }
    }
    private void GrayAmountChanged(int newVal)
    {
        StartCoroutine(LerpGrayAmountValue(newVal, 1f));
        StartCoroutine(ShowAnimGrayAmountChanged());
    }
    IEnumerator LerpGrayAmountValue(float endValue, float duration)
    {
        float time = 0;
        float startValue = _graysAmount;

        while (time < duration)
        {
            _graysAmount = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;
            GraysAmountPerWaveText.text = "X " + Math.Round(_graysAmount, 2).ToString("F0");
            yield return null;
        }
    }

    IEnumerator LerpColor(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            _fillImage.color = Color.Lerp(Color.green, Color.red, _valueToChange);
            yield return null;
        }


        _valueToChange = endValue;
    }

    public IEnumerator ShowAnimGrayAmountChanged()
    {
        GraysAmountPerWaveTextAnim.SetBool("IsGrayAmountChanged", true);
        yield return new WaitForSeconds(1f);
        GraysAmountPerWaveTextAnim.SetBool("IsGrayAmountChanged", false);
    }

    public IEnumerator ShowAnimRoundChanged()
    {
        RoundTextAnim.SetBool("IsNewRound", true);
        yield return new WaitForSeconds(1f);
        RoundTextAnim.SetBool("IsNewRound", false);
    }

    void Update()
    {
        _mySlider.value = GameVars.Values.GetCatDistance();
        if (_mySlider.value < _dangerThreshold)
        {
            StartCoroutine(LerpColor(1f,0.8f)); 
        }
        else
        {
            _fillImage.color = Color.green;
        }
    }

    public void OnNotify(string message)
    {
        if (message.Equals("RoundChanged"))
        {
            RoundText.text = "Round: " + GameVars.Values.WaveManager.GetCurrentRound();
            StartCoroutine(ShowAnimRoundChanged());
        } 
           
    }

    
}
