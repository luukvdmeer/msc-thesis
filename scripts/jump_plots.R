require(ggplot2)

jumpgo = ggplot() +
  geom_point(
    data = data.frame(
      x = c(1:21),
      y = c(rep(c(1:10), 2), 10)
    ),
    mapping = aes(x = x, y = y),
    alpha = 0
  ) +
  scale_x_continuous(
    breaks = seq(0, 21, 3),
    labels = c('01 Mar', '22 Mar', '12 Apr', '03 May', '24 May', '14 Jun', '05 Jul', '21 Jul')
  ) +
  scale_y_continuous(
    breaks = seq(0, 10, 2)
  ) +
  labs(
    x = 'Date in 2018',
    y = 'Trips per bike per day'
  ) +
  theme(
    text = element_text(family = 'sans')
  )

ggsave(
  'figures/jumpgo_blank.png',
  plot = jumpgo,
  width = 5.978,
  height = 3.998,
  unit = 'in',
  dpi = 600
)